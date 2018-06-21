#include <amxmodx>
#include < hamsandwich >

// Можно получить из архива с CSRank
#include < csrank >

#define LOG_FILE "addons/amxmodx/logs/csrViews.log"

new const PLUGIN[]  =   "CSRank::Views"
new const VERSION[] =   "0.2"
new const AUTHOR[]  =   "Rev&Crew"

/*
    Конкретные плагины разрабатывал не я. Я лишь объединил их, добавил квары и сделал поддержку CSRank
    Kill Assist: Digi (a.k.a. Hunter-Digital); URL: http://ya-cs.ru/plugins/2766-kill_assist_v1_2b.html
    3D Rank : Payampap, from youtube

    ПЛАГИН ДЛЯ 1.8.2
*/

/*
    За ассисты будет также выдаваться опыт игрокам
    3d ранк игрока будет высвечиваться в определенные моменты
    При наведении на игрока показывается опыт уровень и тд
*/

// Далее Следует блок для продвинутых юзеров. Точнее для обычных, только нужно еще уметь читать\компилировать

//////////////////////////////// 3D Sprites ////////////////////////
/*
    Благодаря наличию исходника, можно заккоментировать define и перекомпилировать, чтобы убрать функционал
*/

new MaxPlayers
new bool:isAlive[33];

#define ENABLE_3D_RANKS

#if defined ENABLE_3D_RANKS

    // Путь к модели спрайта
    new const gsz_RankModel [ ] = "models/3dranks.mdl"
    new gi_PlayerRank [ 33 ];

	// Настройки
	// Settings for 3D Ranks

	// 0 - показывать всегда, 1 - в начале раунда, 2 - в конце
	// 0 - Display alway, 1 - when round start, 2 - when round end
	#define DISPLAY_TYPE 1

	// Время показа
	#define DISPLAY_TIME 20.0

	// Сколько нужно медалей для ранга
	// How many medals need for rank
	#define RANK_MEDAL_1 0..2
	#define RANK_MEDAL_2 3..7
	#define RANK_MEDAL_3 8..10
	#define RANK_MEDAL_4 11..14
	#define RANK_MEDAL_5 15..17
	#define RANK_MEDAL_6 18..20
	#define RANK_MEDAL_7 21..23
	#define RANK_MEDAL_8 24..26
	#define RANK_MEDAL_9 27..30
	// Последний ранг будет выдаваться если больше
	// Give last rank for player when he has more medals
	//#define RANK_MEDAL_10

	#include <csrank_views/views_3d_rank>
#endif

#define ENABLE_PLAYER_INFO

#if defined ENABLE_PLAYER_INFO
	// Формат отображения: Уровень %level% - опыт %exp% | Медали %medal%
	// Output Format: Level %level% - exp %exp% | Medals %medal%

	#define COORD -1.0, -1.0
	

	// Информация о противнике, если закомментировать, то не будет показываться
	// When uncomment, display info about enemy
	#define INFO_ENEMY

	#include <csrank_views/views_info_player>
#endif
public plugin_precache ( )
{
#if defined ENABLE_3D_RANKS
	rank_precache();
#endif
}

public plugin_init ( )
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	MaxPlayers = get_maxplayers();

#if defined ENABLE_PLAYER_INFO
	register_forward(FM_PlayerPreThink, "fwdPlayerPreThink", 0);
#endif

    RegisterHam ( Ham_Killed, "player", "player_killed", 1 )
    RegisterHam ( Ham_Spawn, "player", "player_spawned", 1 )

#if defined ENABLE_3D_RANKS
	#if DISPLAY_TYPE == 1
	//Register Round Start
	register_logevent( "Round_event", 2, "1=Round_Start" );
	#endif
	#if DISPLAY_TYPE == 2
	//Register Round End
	register_logevent( "Round_event", 2, "1=Round_End" );
	#endif
	
#endif
}
public player_killed ( victim, attacker, gid )
{
	if ( !csr_is_valid_player ( victim ) )	return;

	isAlive[victim] = false;

#if defined ENABLE_3D_RANKS
	if ( csr_is_valid_player ( attacker ) )	check_rank ( attacker )
#endif
}

public player_spawned ( id )
{
	if ( !csr_is_valid_player ( id ) )	return;

	isAlive[id] = true;

#if defined ENABLE_3D_RANKS
	check_rank ( id )
#endif

}

public client_putinserver ( id )
{
#if defined ENABLE_3D_RANKS
	rank_put_in( id );
#endif
}
public client_disconnect ( id )
{
#if defined ENABLE_3D_RANKS
	rank_disc( id );
#endif
}
