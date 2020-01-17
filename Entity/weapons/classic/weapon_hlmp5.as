/***
	From Default Angelscripts sample
***/

class CMP5Grenade : ScriptBaseMonsterEntity
{
	void Spawn()
	{
		Precache();
		
		self.pev.movetype = MOVETYPE_TOSS;
		self.pev.solid = SOLID_BBOX;
		self.m_bloodColor = DONT_BLEED;

		SetTouch( TouchFunction( BounceTouch ) );
		SetThink( ThinkFunction( TumbleThink ) );
		
		g_EntityFuncs.SetModel( self, "models/hlclassic/grenade.mdl" );
		
		self.pev.dmg = 100;
	}
	
	void Precache()
	{
		BaseClass.Precache();
		g_Game.PrecacheModel( "models/hlclassic/grenade.mdl" );
		
		g_SoundSystem.PrecacheSound( "weapons/grenade_hit1.wav" );
		g_SoundSystem.PrecacheSound( "weapons/grenade_hit2.wav" );
		g_SoundSystem.PrecacheSound( "weapons/grenade_hit3.wav" );
	}
	
	void BounceTouch( CBaseEntity@ pOther )
	{
		if(pOther.pev.classname == "trigger_hitbox" && self.pev.owner is pOther.pev.owner)
				return;

		// don't hit the guy that launched this grenade
		if ( pOther.edict() is self.pev.owner )
			return;
		Detonate();
	}
	
	void TumbleThink()
	{
		if ( !self.IsInWorld() )
		{
			CBaseEntity@ pThis = g_EntityFuncs.Instance( self.edict() );
			g_EntityFuncs.Remove( pThis );
			return;
		}
		
		self.StudioFrameAdvance();
		
		//Vector vecAng = self.pev.velocity;
		//g_EngineFuncs.VecToAngles( vecAng, self.pev.angles );
		//self.pev.angles = vecAng;
		
		self.pev.nextthink = g_Engine.time + 0.1;
		if ( self.pev.waterlevel != 0 )
		{
			self.pev.velocity = self.pev.velocity * 0.5;
			self.pev.framerate = 0.2;
		}
	}
	
	void Detonate()
	{
		CBaseEntity@ pThis = g_EntityFuncs.Instance( self.edict() );
		
		TraceResult tr;
		Vector vecSpot; // trace starts here!
		
		vecSpot = self.pev.origin + Vector ( 0, 0, 8 );
		g_Utility.TraceLine( vecSpot, vecSpot + Vector ( 0, 0, -40 ), ignore_monsters, self.edict(), tr );
		
		g_EntityFuncs.CreateExplosion( tr.vecEndPos, Vector( 0, 0, -90 ), self.pev.owner, int( self.pev.dmg ), false ); // Effect
		g_WeaponFuncs.RadiusDamage( tr.vecEndPos, self.pev, self.pev.owner.vars, self.pev.dmg, ( self.pev.dmg * 3.0 ), CLASS_NONE, DMG_BLAST );
		
		g_EntityFuncs.Remove( pThis );
	}
}

CBaseEntity@ ShootARGrenade( entvars_t@ pevOwner, Vector& in vecStart, Vector& in vecVelocity)
{
	CBaseEntity@ pGrenade = g_EntityFuncs.CreateEntity( "hlargrenade", null, false );
	pGrenade.pev.origin = vecStart;
	pGrenade.pev.velocity = vecVelocity;
	g_EngineFuncs.VecToAngles( pGrenade.pev.velocity, pGrenade.pev.angles );
	
	CBaseEntity@ pOwner = g_EntityFuncs.Instance( pevOwner );
	@pGrenade.pev.owner = @pOwner.edict();

	pGrenade.pev.nextthink = g_Engine.time + 0.1;
	pGrenade.pev.sequence = Math.RandomLong( 3, 6 );
	pGrenade.pev.framerate = 1.0;
	pGrenade.pev.dmg = 100;

	g_EntityFuncs.DispatchSpawn(pGrenade.edict());

	return pGrenade;
}


class weapon_hlmp5 : ScriptBasePlayerWeaponEntity
{
	private CBasePlayer@ m_pPlayer = null;
	private float m_flNextAnimTime;
	private int m_iShell,m_iSecondaryAmmo;
	void Spawn()
	{
		Precache();
		g_EntityFuncs.SetModel( self, "models/hlclassic/w_9mmAR.mdl" );
		self.m_iDefaultAmmo = 100;
		self.m_iClip = 25;
		self.m_iSecondaryAmmoType = 0;
		self.FallInit();
	}
	void Precache()
	{
		self.PrecacheCustomModels();
		g_Game.PrecacheOther("hlargrenade");
		g_Game.PrecacheModel( "models/hlclassic/v_9mmAR.mdl" );
		g_Game.PrecacheModel( "models/hlclassic/w_9mmAR.mdl" );
		g_Game.PrecacheModel( "models/hlclassic/p_9mmAR.mdl" );
		m_iShell = g_Game.PrecacheModel( "models/shell.mdl" );
		g_Game.PrecacheModel( "models/grenade.mdl" );
		g_Game.PrecacheModel( "models/w_9mmARclip.mdl" );
		g_SoundSystem.PrecacheSound( "items/9mmclip1.wav" );              
		g_SoundSystem.PrecacheSound( "hlclassic/items/clipinsert1.wav" );
		g_SoundSystem.PrecacheSound( "hlclassic/items/cliprelease1.wav" );
		g_SoundSystem.PrecacheSound( "hlclassic/items/guncock1.wav" );
		g_SoundSystem.PrecacheSound( "hlclassic/weapons/hks1.wav" );
		g_SoundSystem.PrecacheSound( "hlclassic/weapons/hks2.wav" );
		g_SoundSystem.PrecacheSound( "hlclassic/weapons/hks3.wav" );
		g_SoundSystem.PrecacheSound( "hlclassic/weapons/glauncher.wav" );
		g_SoundSystem.PrecacheSound( "hlclassic/weapons/glauncher2.wav" );
		g_SoundSystem.PrecacheSound( "hlclassic/weapons/357_cock1.wav" );
	}
	bool GetItemInfo( ItemInfo& out info )
	{
		info.iMaxAmmo1 	= 250;
		info.iMaxAmmo2 	= 10;
		info.iMaxClip 	= 50;
		info.iSlot 		= 2;
		info.iPosition 	= 4;
		info.iFlags 	= 0;
		info.iWeight 	= 5;
		return true;
	}
	bool AddToPlayer( CBasePlayer@ pPlayer )
	{
		if( !BaseClass.AddToPlayer( pPlayer ) )
			return false;
		@m_pPlayer = pPlayer;
		NetworkMessage message( MSG_ONE, NetworkMessages::WeapPickup, pPlayer.edict() );
			message.WriteLong( self.m_iId );
		message.End();
		return true;
	}
	bool PlayEmptySound()
	{
		if( self.m_bPlayEmptySound )
		{
			self.m_bPlayEmptySound = false;
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hlclassic/weapons/357_cock1.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		}
		return false;
	}
	bool Deploy()
	{
		return self.DefaultDeploy( self.GetV_Model( "models/hlclassic/v_9mmAR.mdl" ), self.GetP_Model( "models/hlclassic/p_9mmAR.mdl" ), 4, "mp5" );
	}
	float WeaponTimeBase()
	{
		return g_Engine.time;
	}
	void PrimaryAttack()
	{
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD ){
			self.PlayEmptySound( );
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15;
			return;}
		if( self.m_iClip <= 0 ){
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15;
			return;}
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = NORMAL_GUN_FLASH;
		--self.m_iClip;
		switch ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 2 ) ){
			case 0: self.SendWeaponAnim( 5, 0, 0 ); break;
			case 1: self.SendWeaponAnim( 6, 0, 0 ); break;
			case 2: self.SendWeaponAnim( 7, 0, 0 ); break;}
		g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hlclassic/weapons/hks1.wav", 1.0, ATTN_NORM, 0, 95 + Math.RandomLong( 0, 10 ) );
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		Vector vecSrc	 = m_pPlayer.GetGunPosition();
		Vector vecAiming = m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		m_pPlayer.FireBullets( 1, vecSrc, vecAiming, VECTOR_CONE_6DEGREES, 8192, BULLET_PLAYER_MP5, 0 );
		Vector vecShellVelocity = m_pPlayer.pev.velocity + g_Engine.v_right * Math.RandomFloat( 50.0, 70.0 ) + g_Engine.v_up * Math.RandomFloat( 100.0, 150.0 ) + g_Engine.v_forward * 25;
		g_EntityFuncs.EjectBrass(m_pPlayer.GetGunPosition() + g_Engine.v_up * -5 + g_Engine.v_forward * 17 + g_Engine.v_right * 5, vecShellVelocity, m_pPlayer.pev.angles[1], m_iShell, TE_BOUNCE_SHELL );
		if( self.m_iClip == 0 && m_pPlayer.m_rgAmmo( self.m_iPrimaryAmmoType ) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
		m_pPlayer.pev.punchangle.x = Math.RandomLong( -2, 2 );
		self.m_flNextPrimaryAttack = self.m_flNextPrimaryAttack + 0.1;
		if( self.m_flNextPrimaryAttack < WeaponTimeBase() )
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.1;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );
	}
	void SecondaryAttack()
	{
		if( m_pPlayer.pev.waterlevel == WATERLEVEL_HEAD ){
			self.PlayEmptySound();
			self.m_flNextPrimaryAttack = WeaponTimeBase() + 0.15;
			return;}
		if( m_pPlayer.m_rgAmmo(self.m_iSecondaryAmmoType) <= 0 ){
			self.PlayEmptySound();
			return;}
		m_pPlayer.m_iWeaponVolume = NORMAL_GUN_VOLUME;
		m_pPlayer.m_iWeaponFlash = BRIGHT_GUN_FLASH;
		m_pPlayer.m_iExtraSoundTypes = bits_SOUND_DANGER;
		m_pPlayer.m_flStopExtraSoundTime = WeaponTimeBase() + 0.2;
		m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType, m_pPlayer.m_rgAmmo( self.m_iSecondaryAmmoType ) - 1 );
		m_pPlayer.pev.punchangle.x = -10.0;
		self.SendWeaponAnim( 2 );
		m_pPlayer.SetAnimation( PLAYER_ATTACK1 );
		if ( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed, 0, 1 ) != 0 )
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hlclassic/weapons/glauncher.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		else
			g_SoundSystem.EmitSoundDyn( m_pPlayer.edict(), CHAN_WEAPON, "hlclassic/weapons/glauncher2.wav", 0.8, ATTN_NORM, 0, PITCH_NORM );
		Math.MakeVectors( m_pPlayer.pev.v_angle + m_pPlayer.pev.punchangle );
		if( ( m_pPlayer.pev.button & IN_DUCK ) != 0 )
			ShootARGrenade( m_pPlayer.pev, m_pPlayer.pev.origin + g_Engine.v_forward * 16 + g_Engine.v_right * 6, g_Engine.v_forward * 800 );
		else
			ShootARGrenade( m_pPlayer.pev,  m_pPlayer.pev.origin + m_pPlayer.pev.view_ofs * 0.5 + g_Engine.v_forward * 16 + g_Engine.v_right * 6, g_Engine.v_forward * 800 );
		self.m_flNextPrimaryAttack = WeaponTimeBase() + 1;
		self.m_flNextSecondaryAttack = WeaponTimeBase() + 1;
		self.m_flTimeWeaponIdle = WeaponTimeBase() + 5;
		if( m_pPlayer.m_rgAmmo(self.m_iSecondaryAmmoType) <= 0 )
			m_pPlayer.SetSuitUpdate( "!HEV_AMO0", false, 0 );
	}
	void Reload()
	{
		self.DefaultReload( 50, 3, 1.5, 0 );
		BaseClass.Reload();
	}
	void WeaponIdle()
	{
		self.ResetEmptySound();
		m_pPlayer.GetAutoaimVector( AUTOAIM_5DEGREES );
		if( self.m_flTimeWeaponIdle > WeaponTimeBase() )
			return;
		int iAnim;
		switch( g_PlayerFuncs.SharedRandomLong( m_pPlayer.random_seed,  0, 1 ) ){
			case 0:	iAnim = 0;break;
			case 1:iAnim = 1;break;
			default:iAnim = 1;break;}
		self.SendWeaponAnim( iAnim );
		self.m_flTimeWeaponIdle = WeaponTimeBase() + g_PlayerFuncs.SharedRandomFloat( m_pPlayer.random_seed,  10, 15 );
	}
}

void RegisterDMMP5()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CMP5Grenade", "hlargrenade" );
	g_CustomEntityFuncs.RegisterCustomEntity( "weapon_hlmp5", "weapon_hlmp5" );
	g_ItemRegistry.RegisterWeapon( "weapon_hlmp5", "hl_weapons", "9mm", "ARgrenades" );
}