namespace pvpHitbox
{
    class info_hitbox : CBaseMonster
    {
        CBasePlayer@ m_pPlayer = null;
        //使用构造函数传递属主xue
        info_hitbox()
        {
            //pPlayer.pev.edict() = pev.owner;
        }

        void Spawn()
        {
            //把属主找到存进m_pPlayer里
            @m_pPlayer = g_EntityFuncs.insance(pev.owner.vars);
        }

        int DeliverDamage(float&in Ap, float&in Hp)
        {
            //扣血扣甲

            //如果死亡将玩家传递死亡，并用keyvalue标记为已死
            
            //此时返回1
            return 1;
            //0代表正常,玩家未死
            return 0;
        }

        void Hurt()
        {
            //先修改伤害信息
            //先获取属主血量护甲量
            float pPlayerHp;
            float pPlayerAp;
            //计算护甲减伤，算出扣甲量
            float doApDamage;
            //计算扣血量
            float doHpDamage;
            //然后传递给属主
            DeliverDamage(doApDamage, doHpDamage);
            //直接结束，不call原来的
        }
    }
}
