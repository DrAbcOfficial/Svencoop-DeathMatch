const bool m_bDamageOtherPlayers		= true;//Set this to true to make C4 deal damage to other players.
const bool m_bUseBombZones				= true;//Set this to true to only allow the C4 to be placed within range of an info_bomb_target
const int C4_MAX_CARRY					= 1;//1 by default
const int C4_WEIGHT 					= 3;
const float C4_DAMAGE					= 99999;//100 by default
const float C4_TIMER					= 45;//45 by default
const int C4_SLOT						= 5;
const int C4_POSITION					= 11;
const int C4_BOMB_RADIUS				= 500;//500 by default
const int C4_DEFUSE_TIME 				= 15;
const float C4_DELAY_FAIL				= 1;

const string C4_MODEL_VIEW				= "models/cs16/c4/v_c4.mdl";
const string C4_MODEL_PLAYER			= "models/cs16/c4/p_c4.mdl";
const string C4_MODEL_WORLD				= "models/cs16/c4/w_c4.mdl";
const string C4_MODEL_BP				= "models/cs16/c4/w_backpack.mdl";

const string C4_SOUND_PLANT				= "weapons/cs16/c4_plant.wav";
const string C4_SOUND_BEEP				= "weapons/cs16/c4_beep.wav";
const string C4_SOUND_EXPLODE			= "weapons/cs16/c4_explode1.wav";
const string C4_SOUND_BOMBPLANT			= "weapons/cs16/c4_bombpl.wav";

const string C4_PLANT_AT_BOMB_SPOT		= "C4 must be planted at a bomb site!\n";
const string C4_PLANT_MUST_BE_ON_GROUND	= "You must be standing on\nthe ground to plant the C4!\n";
const string C4_ARMING_CANCELLED		= "Arming Sequence Cancelled\nC4 can only be placed at a Bomb Target.\n";
const string C4_BOMB_PLANTED			= "The bomb has been planted!\n";
const string C4_DIFUSEING               = "You are defusing C4\nWait for ";

float m_flNextBlink;

enum c4_e
{
	C4_IDLE1 = 0,
	C4_DRAW,
	C4_DROP,
	C4_ARM
};

class CWeaponC4 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	bool m_bStartedArming, m_bBombPlacedAnimation;
	float m_fArmedTime;

	void Spawn()
	{
		g_EntityFuncs.SetModel( self, C4_MODEL_BP );
		self.m_iDefaultAmmo = 1;
		m_bStartedArming = false;
		m_fArmedTime = 0;

		self.FallInit();
	}

	void Precache()
	{
		self.PrecacheCustomModels();

		g_Game.PrecacheModel( C4_MODEL_VIEW );
		g_Game.PrecacheModel( C4_MODEL_PLAYER );
		g_Game.PrecacheModel( C4_MODEL_WORLD );
		g_Game.PrecacheModel( C4_MODEL_BP );
		g_Game.PrecacheModel( "sprites/zerogxplode.spr" );
		g_Game.PrecacheModel( "sprites/eexplo.spr" );
		g_Game.PrecacheModel( "sprites/fexplo.spr" );
		g_Game.PrecacheModel( "sprites/steam1.spr" );
		g_Game.PrecacheModel( "sprites/ledglow.spr" );

		g_SoundSystem.PrecacheSound( "weapons/debris1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/debris2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/debris2.wav" );

		g_SoundSystem.PrecacheSound( C4_SOUND_BEEP );
		g_SoundSystem.PrecacheSound( C4_SOUND_BOMBPLANT );
		g_SoundSystem.PrecacheSound( C4_SOUND_EXPLODE );
		g_SoundSystem.PrecacheSound( C4_SOUND_PLANT );

		//Precache these for downloading
		g_Game.PrecacheGeneric( "sound/" + C4_SOUND_BEEP );
		g_Game.PrecacheGeneric( "sound/" + C4_SOUND_BOMBPLANT );
		g_Game.PrecacheGeneric( "sound/" + C4_SOUND_EXPLODE );
		g_Game.PrecacheGeneric( "sound/" + C4_SOUND_PLANT );

		g_Game.PrecacheGeneric( "sprites/cs16/weapon_c4.txt" );
		g_Game.PrecacheGeneric( "sprites/cs16/640hud1.spr" );
		g_Game.PrecacheGeneric( "sprites/cs16/640hud4.spr" );
		g_Game.PrecacheGeneric( "sprites/cs16/640hud7.spr" );
	}

	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= C4_MAX_CARRY;
		info.iMaxClip 	= WEAPON_NOCLIP;
		info.iSlot 		= C4_SLOT-1;
		info.iPosition 	= C4_POSITION-1;
		info.iFlags 	= ITEM_FLAG_LIMITINWORLD | ITEM_FLAG_EXHAUSTIBLE ;
		info.iWeight 	= C4_WEIGHT;

		return true;
	}

	void Materialize()
	{
		BaseClass.Materialize();
		SetTouch( TouchFunction( CustomTouch ) );
		SetUse( UseFunction( CustomUse ) );
	}

	void CustomUse( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
    {
		CBasePlayer@ pPlayer = cast<CBasePlayer@>( pActivator );
        if(pvpUtility::IsPlayerAlive(pPlayer))
        {
			if(pPlayer.pev.team == CS::CTClass)
				return;
			else if( pPlayer.AddPlayerItem( self ) != APIR_NotAdded )
			{
				g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM );
				self.DestroyItem();
				pPlayer.GiveNamedItem( "weapon_c4" , 0 , 0 );
			}
        }
    }

	void CustomTouch( CBaseEntity@ pOther ) 
	{
		if( !pOther.IsPlayer() )
			return;
		
		CBasePlayer@ pPlayer = cast<CBasePlayer@>( pOther );
		if( pPlayer.pev.team == CS::CTClass )
	  		return;
		else if( pPlayer.AddPlayerItem( self ) != APIR_NotAdded )
		{
	  		g_SoundSystem.EmitSound( self.edict(), CHAN_ITEM, "items/gunpickup2.wav", 1, ATTN_NORM );
			self.SUB_Remove();
			pPlayer.GiveNamedItem( "weapon_c4" , 0 , 0 );
		}
	}

	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( BaseClass.AddToPlayer( pPlayer ) )
		{
			@m_pPlayer = pPlayer;
			NetworkMessage csc4( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
				csc4.WriteLong( g_ItemRegistry.GetIdForName("weapon_c4") );
			csc4.End();

			return true;
		}

		return false;
	}

	bool Deploy()
	{
		bool bResult;
		{
			m_bStartedArming = false;
			m_fArmedTime = 0;
			bResult = self.DefaultDeploy( self.GetV_Model( C4_MODEL_VIEW ), self.GetP_Model( C4_MODEL_PLAYER ), C4_DRAW, "trip" );
			self.m_flTimeWeaponIdle = self.m_flNextPrimaryAttack = self.m_flNextSecondaryAttack = g_Engine.time + 1.3f;
			return bResult;
		}
	}

	void Holster( int skipLocal = 0 )
	{
		m_bStartedArming = false;
		SetThink(null);
		m_pPlayer.pev.maxspeed = 0;

		BaseClass.Holster( skipLocal );
	}

	void PrimaryAttack()
	{
		bool onGround = (m_pPlayer.pev.flags & FL_ONGROUND) != 0;
		CustomKeyvalues@ pCustom = m_pPlayer.GetCustomKeyvalues();
		bool onBombZone = pCustom.GetKeyvalue( "$i_inBombZone" ).GetInteger() == 1;

		if( !m_bStartedArming )
		{
			if( !onBombZone && m_bUseBombZones )
			{
				g_PlayerFuncs.ClientPrint( m_pPlayer, HUD_PRINTCENTER, C4_PLANT_AT_BOMB_SPOT );
				self.m_flNextPrimaryAttack = g_Engine.time + C4_DELAY_FAIL;
				return;
			}

			if( !onGround )
			{
				g_PlayerFuncs.ClientPrint( m_pPlayer, HUD_PRINTCENTER, C4_PLANT_MUST_BE_ON_GROUND );
				self.m_flNextPrimaryAttack = g_Engine.time + C4_DELAY_FAIL;
				return;
			}

			m_pPlayer.pev.maxspeed = 1;

			m_bStartedArming = true;
			m_bBombPlacedAnimation = false;
			m_fArmedTime = g_Engine.time + 3;
			self.SendWeaponAnim( C4_ARM );
			m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
			//m_pPlayer.SetProgressBarTime(3);
			self.m_flNextPrimaryAttack = g_Engine.time + 0.3f;
			self.m_flTimeWeaponIdle = g_Engine.time + Math.RandomFloat( 10, 15 );
		}
		else
		{
			if( !onGround || (!onBombZone && m_bUseBombZones) )
			{
				if( onBombZone && m_bUseBombZones )
					g_PlayerFuncs.ClientPrint( m_pPlayer, HUD_PRINTCENTER, C4_PLANT_MUST_BE_ON_GROUND );
				else
					g_PlayerFuncs.ClientPrint( m_pPlayer, HUD_PRINTCENTER, C4_ARMING_CANCELLED );

				m_bStartedArming = false;
				self.m_flNextPrimaryAttack = g_Engine.time + 1.5f;
				m_pPlayer.pev.maxspeed = 0;
				//m_pPlayer.SetProgressBarTime(0);
				//m_pPlayer.SetAnimation( PLAYER_HOLDBOMB );

				if( m_bBombPlacedAnimation == true )
					self.SendWeaponAnim( C4_DRAW );
				else
					self.SendWeaponAnim( C4_IDLE1 );

				return;
			}

			if( g_Engine.time > m_fArmedTime )
			{
				if( m_bStartedArming == true )
				{
					m_bStartedArming = false;
					m_fArmedTime = 0;
					g_SoundSystem.PlaySound( m_pPlayer.edict(), CHAN_STATIC, C4_SOUND_BOMBPLANT, 1, ATTN_NORM );

					cs16_PlantC4( m_pPlayer, m_pPlayer.pev.origin, Vector(0, 0, 0), g_Engine.time + C4_TIMER );

					g_PlayerFuncs.ClientPrintAll( HUD_PRINTCENTER, C4_BOMB_PLANTED );

					g_SoundSystem.EmitSound( m_pPlayer.edict(), CHAN_WEAPON, C4_SOUND_PLANT, VOL_NORM, ATTN_NORM );

					m_pPlayer.pev.maxspeed = 0;
					//m_pPlayer.SetBombIcon(FALSE);
					m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType, m_pPlayer.m_rgAmmo(self.m_iPrimaryAmmoType) - 1 );

					CS::IsBlockTimer = true;

					if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
					{
						//self.RetireWeapon();
						//self.SUB_Remove();
						g_EntityFuncs.Remove(self);
						return;
					}
				}
			}
			else
			{
				if( g_Engine.time >= m_fArmedTime - 0.75f )
				{
					if( m_bBombPlacedAnimation == false )
					{
						m_bBombPlacedAnimation = true;
						self.SendWeaponAnim( C4_DROP );
						SetThink( ThinkFunction( DrawThink ) );
						self.pev.nextthink = g_Engine.time + 0.5;
						//m_pPlayer.SetAnimation( PLAYER_HOLDBOMB );
					}
				}
			}
		}

		self.m_flNextPrimaryAttack = g_Engine.time + 0.3f;
		self.m_flTimeWeaponIdle = g_Engine.time + Math.RandomFloat( 10, 15 );
	}

	void DrawThink()
	{
		self.SendWeaponAnim( C4_DRAW );
	}

	void WeaponIdle()
	{
		if( m_bStartedArming == true )
		{
			m_bStartedArming = false;
			m_pPlayer.pev.maxspeed = 0;
			self.m_flNextPrimaryAttack = g_Engine.time + 1;
			//m_pPlayer.SetProgressBarTime( 0 );

			if( m_bBombPlacedAnimation == true )
				self.SendWeaponAnim( C4_DRAW );
			else
				self.SendWeaponAnim( C4_IDLE1 );
		}

		if( self.m_flTimeWeaponIdle <= g_Engine.time )
		{
			if( m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			{
				self.RetireWeapon();
				return;
			}

			self.SendWeaponAnim( C4_DRAW );
			self.SendWeaponAnim( C4_IDLE1 );
		}
	}
}

class CC4 : ScriptBasePlayerAmmoEntity
{
	float m_flSoundTime, m_flBeepTime, m_flDefuseTime;
	bool m_bIsDefusing = false;
	CBasePlayer@ pDefuser = null;

	void Spawn()
	{
		g_EntityFuncs.SetModel( self, C4_MODEL_WORLD );
		g_EntityFuncs.SetSize( self.pev, Vector(-3, -6, 0), Vector(3, 6, 8) );
        //g_EntityFuncs.SetSize( self.pev, VEC_HUMAN_HULL_MIN, VEC_HUMAN_HULL_MAX );
		g_EntityFuncs.SetOrigin( self, self.pev.origin );
		self.pev.nextthink = g_Engine.time + 0.1f;
		self.pev.movetype = MOVETYPE_TOSS;
		self.pev.solid = SOLID_TRIGGER;
		self.pev.dmg = C4_DAMAGE;


		if( self.pev.dmgtime - g_Engine.time <= 10.0f )
			m_flBeepTime = 5;
		else
			m_flBeepTime = C4_TIMER;

		SetThink( ThinkFunction(C4_Think) );
        SetUse( UseFunction(C4_Use));
	}

	void C4_Think()
	{
		if( self.pev.dmgtime <= g_Engine.time )
		{
			SetThink( ThinkFunction(C4_Detonate) );
			self.pev.nextthink = g_Engine.time + self.pev.dmgtime;
		}

		if( g_Engine.time >= m_flSoundTime )
		{
			g_SoundSystem.EmitSound( self.edict(), CHAN_STATIC, C4_SOUND_BEEP, 1, ATTN_NORM );
			m_flSoundTime = g_Engine.time + (m_flBeepTime/10);
		}

	   if( g_Engine.time >= m_flNextBlink )
	   {
			m_flNextBlink = g_Engine.time + 2;

			NetworkMessage c4glow( MSG_PAS, NetworkMessages::SVC_TEMPENTITY, self.pev.origin );
					c4glow.WriteByte( TE_GLOWSPRITE );
					c4glow.WriteCoord( self.pev.origin.x );
					c4glow.WriteCoord( self.pev.origin.y );
					c4glow.WriteCoord( self.pev.origin.z + 5 );
					c4glow.WriteShort( g_EngineFuncs.ModelIndex("sprites/ledglow.spr") );
					c4glow.WriteByte( 1 );
					c4glow.WriteByte( 3 );
					c4glow.WriteByte( 255 );
			c4glow.End();
	   }

		if(@pDefuser !is null)
		{
			Vector vecTemp = pDefuser.GetGunPosition() - pev.origin;
			Vector vecSrc	 = pDefuser.GetGunPosition();
			TraceResult tr;
			Vector vecEnd = vecSrc + pDefuser.GetAutoaimVector( AUTOAIM_5DEGREES ) * 128;
			g_Utility.TraceLine( vecSrc, vecEnd, dont_ignore_monsters, pDefuser.edict(), tr );
			if (vecTemp.Length() <= 90.0f && (tr.vecEndPos - self.pev.origin).Length() < 10.0f)
			{
				g_PlayerFuncs.ClientPrint(pDefuser, HUD_PRINTCENTER, C4_DIFUSEING + Math.Floor(C4_DEFUSE_TIME - g_Engine.time + m_flDefuseTime) + " secconds." );
			}
			else
			{
				g_PlayerFuncs.ClientPrint(pDefuser, HUD_PRINTCENTER, "" );
				@pDefuser = null;
				m_bIsDefusing = false;
				m_flDefuseTime = 0;
			}
		}

		if(m_flDefuseTime > 0)
		{
			if(C4_DEFUSE_TIME - g_Engine.time + m_flDefuseTime <= 0)
			{
				if(!CS::IsRestarting)
					CS::RoundEnd(CS::CT_WIN);
				self.SUB_Remove();
			}
		}
		m_flBeepTime -= 0.1f;
		self.pev.nextthink = g_Engine.time + 0.1f;
	}

	void C4_Detonate()
	{
		TraceResult tr;
		Vector vecSpot = self.pev.origin + Vector(0, 0, 8);
		g_Utility.TraceLine( vecSpot, vecSpot + Vector(0, 0, -40), ignore_monsters, self.edict(), tr );
		C4_Explode( tr, DMG_BLAST );
	}

	void C4_Explode( TraceResult &in pTrace, int bitsDamageType )
	{
		self.pev.model = string_t();
		self.pev.solid = SOLID_NOT;
		self.pev.takedamage = DAMAGE_NO;
		g_PlayerFuncs.ScreenShake( pTrace.vecEndPos, 25, 150, 1, 3000 );

		int iContents = g_EngineFuncs.PointContents( self.pev.origin );

		NetworkMessage c4x1( MSG_PAS, NetworkMessages::SVC_TEMPENTITY, self.pev.origin );
				c4x1.WriteByte( TE_SPRITE );
				c4x1.WriteCoord( self.pev.origin.x );
				c4x1.WriteCoord( self.pev.origin.y );
				c4x1.WriteCoord( self.pev.origin.z - 10 );
				c4x1.WriteShort( g_EngineFuncs.ModelIndex("sprites/fexplo.spr") );
				c4x1.WriteByte( int(self.pev.dmg - 275) );
				c4x1.WriteByte( 150 );
		c4x1.End();

		NetworkMessage c4x2( MSG_PAS, NetworkMessages::SVC_TEMPENTITY, self.pev.origin );
				c4x2.WriteByte( TE_SPRITE );
				c4x2.WriteCoord( self.pev.origin.x + Math.RandomFloat(-512, 512) );
				c4x2.WriteCoord( self.pev.origin.y + Math.RandomFloat(-512, 512) );
				c4x2.WriteCoord( self.pev.origin.z + Math.RandomFloat(-10, 10) );
				c4x2.WriteShort( g_EngineFuncs.ModelIndex("sprites/eexplo.spr") );
				c4x2.WriteByte( int(self.pev.dmg - 275) );
				c4x2.WriteByte( 150 );
		c4x2.End();

		NetworkMessage c4x3( MSG_PAS, NetworkMessages::SVC_TEMPENTITY, self.pev.origin );
				c4x3.WriteByte( TE_SPRITE );
				c4x3.WriteCoord( self.pev.origin.x + Math.RandomFloat(-512, 512) );
				c4x3.WriteCoord( self.pev.origin.y + Math.RandomFloat(-512, 512) );
				c4x3.WriteCoord( self.pev.origin.z + Math.RandomFloat(-10, 10) );
				c4x3.WriteShort( g_EngineFuncs.ModelIndex("sprites/fexplo.spr") );
				c4x3.WriteByte( int(self.pev.dmg - 275) );
				c4x3.WriteByte( 150 );
		c4x3.End();

		NetworkMessage c4x4( MSG_PAS, NetworkMessages::SVC_TEMPENTITY, self.pev.origin );
				c4x4.WriteByte( TE_SPRITE );
				c4x4.WriteCoord( self.pev.origin.x + Math.RandomFloat(-512, 512) );
				c4x4.WriteCoord( self.pev.origin.y + Math.RandomFloat(-512, 512) );
				c4x4.WriteCoord( self.pev.origin.z + Math.RandomFloat(-10, 10) );
				c4x4.WriteShort( g_EngineFuncs.ModelIndex("sprites/zerogxplode.spr") );
				c4x4.WriteByte( int(self.pev.dmg - 275) );
				c4x4.WriteByte( 17 );
		c4x4.End();

		g_SoundSystem.EmitSound( self.edict(), CHAN_WEAPON, C4_SOUND_EXPLODE, 1, ATTN_NORM );

		entvars_t@ pevOwner;

		if( self.pev.owner !is null )
			@pevOwner = self.pev.owner.vars;
		else
			@pevOwner = null;

		CSMenu::AddMoney(pvpUtility::getSteamId(cast<CBasePlayer@>(g_EntityFuncs.Instance(pev.owner))), 300);

		@self.pev.owner = null;
		
		if( m_bDamageOtherPlayers )
			g_WeaponFuncs.RadiusDamage( self.pev.origin, self.pev, g_EntityFuncs.Instance(0).pev, C4_DAMAGE, C4_BOMB_RADIUS, CLASS_NONE, bitsDamageType );
		else
			g_WeaponFuncs.RadiusDamage( self.pev.origin, self.pev, pevOwner, C4_DAMAGE, C4_BOMB_RADIUS, CLASS_NONE, bitsDamageType );

		if( Math.RandomFloat(0, 1) < 0.5f )
			g_Utility.DecalTrace( pTrace, DECAL_SCORCH1 );
		else
			g_Utility.DecalTrace( pTrace, DECAL_SCORCH2 );

		switch( Math.RandomLong(0, 2) )
		{
			case 0: g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "weapons/debris1.wav", 0.55f, ATTN_NORM ); break;
			case 1: g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "weapons/debris2.wav", 0.55f, ATTN_NORM ); break;
			case 2: g_SoundSystem.EmitSound( self.edict(), CHAN_VOICE, "weapons/debris3.wav", 0.55f, ATTN_NORM ); break;
		}

		self.pev.effects |= EF_NODRAW;
		SetThink( ThinkFunction(C4_Smoke) );
		self.pev.velocity = g_vecZero;
		self.pev.nextthink = g_Engine.time + 0.85f;

		if( iContents != CONTENTS_WATER )
		{
			int sparkCount = Math.RandomLong(0, 3);

			for( int i = 0; i < sparkCount; i++ )
				g_EntityFuncs.Create( "spark_shower", self.pev.origin, pTrace.vecPlaneNormal, false );
		}
		if(!CS::IsRestarting)
			CS::RoundEnd(CS::TE_WIN);
	}

	void C4_Smoke()
	{
		if( g_EngineFuncs.PointContents(self.pev.origin) != CONTENTS_WATER )
		{
			NetworkMessage c4smoke( MSG_PVS, NetworkMessages::SVC_TEMPENTITY, self.pev.origin );
					c4smoke.WriteByte( TE_SMOKE );
					c4smoke.WriteCoord( self.pev.origin.x );
					c4smoke.WriteCoord( self.pev.origin.y );
					c4smoke.WriteCoord( self.pev.origin.z );
					c4smoke.WriteShort( g_EngineFuncs.ModelIndex( "sprites/steam1.spr" ) );
					c4smoke.WriteByte( 150 );
					c4smoke.WriteByte( 8 );
			c4smoke.End();
		}
		else
			g_Utility.Bubbles( self.pev.origin - Vector(64, 64, 64), self.pev.origin + Vector(64, 64, 64), 100 );

		g_EntityFuncs.Remove( self );
	}

    void C4_Use( CBaseEntity@ pActivator, CBaseEntity@ pCaller, USE_TYPE useType, float value )
    {
        if(pvpUtility::IsPlayerAlive(pActivator) && !m_bIsDefusing)
        {
			if(pActivator.pev.team != CS::CTClass)
				return;
			m_flDefuseTime = g_Engine.time;
			@pDefuser = cast<CBasePlayer@>(@pActivator);
			m_bIsDefusing = true;
        }
    }
}

CBaseEntity@ cs16_PlantC4( CBaseEntity@ owner, Vector origin, Vector angles, float time )
{
	CBaseEntity@ pC4 = g_EntityFuncs.Create( "c4", origin, angles, true, owner.edict() );

	pC4.pev.dmgtime = time;
	m_flNextBlink = g_Engine.time + 2;

	g_EntityFuncs.DispatchSpawn( pC4.edict() );

	return pC4;
}

void RegisterC4()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CWeaponC4", "weapon_c4" );
	g_ItemRegistry.RegisterWeapon( "weapon_c4", "cs16", "c4" );

	g_CustomEntityFuncs.RegisterCustomEntity( "CC4", "c4" );
}