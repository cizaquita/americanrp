/*===============================================================================================
========================|               American RolePlay               |========================
========================|              Scripter: JG-Studio              |========================
========================|              Mappers: JG-Design               |========================
========================|            Web Scripter: JG-Studio            |========================
========================|            Fecha Inicio: 07/11/2016           |========================
========================|               Versión GM: 1.1.8               |========================
========================|           Fecha Update: 12/06/2017            |========================
=================================================================================================*/
#include <a_samp>
#include <YSI\y_commands>
#include <YSI\y_ini>
#include <YSI/y_iterate>
#include <sscanf2>
/* ---===[- Macros & Demas -]===--- */
#define Server_Logo      "{005EF6}» {FFFFFF}Bienvenido a la comunidad de {484EFA}American{FFFFFF} Role{FFFF00}Play!"
#define Server_Version   "v1.1"
#define Server_GameText  "Roleplay | v1.1"
#define Server_Web       "www.proximamente.net"
#define Server_Nombre    "American RolePlay ~ Una nueva aventura"
#define Server_Rcon      "amrp12sv"
#define Server_Map       "San Fierro"
#define Server_Language  "Español / Spanish"
#define Server_Password  ""
/* ---===[- Chat -]===--- */
#define	AdminMsg    "{A7A7A7}[Administración]: "
#define InfoMsg     "{48A4FF}[Información]: "
#define VIPMsg      "{FFFF80}[{FFFFFF}CHAT VIP{FFFF80}]: "
#define InfMsg    "{FF9191}[Info]: "
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define MAX_PLAYER_VIDA                     (80)
#define MAX_PLAYER_CHALECO                  (80)
#define MAX_TEXT_CHAT                       (150)
#define MAX_TEXTOS_CORTOS                   (30)
#define MAX_TEXTOS_LARGOS                   (80)
#define MAX_GUARDADO             			(50)
#define MAX_PLAYER_ACCOUNT_DATA             (60)
#define MAX_INTENTOS     		            (3)
#define MAX_PLAYER_PASS                     (50)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define DIALOG_REGISTRO   (1)
#define DIALOG_LOGUEO     (2)
#define DIALOG_SEXO       (3)
#define DIALOG_EDAD       (4)
#define DIALOG_CIUDAD     (5)
#define DIALOG_AYUDA      (6)
#define DIALOG_CHECK_MAIL (7)
#define DIALOG_STATS      (8)
#define DIALOG_PASAPORTE  (9)
#define DIALOG_VIP        (10)
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define PLAYER_START_LEVEL      (1)
#define MIN_ACCOUNT_CHAR        (4)
#define PLAYER_START_MONEY      (1200)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#define strcmpEx(%0,%1) 				strcmp(%0, %1, true) == 0
#define CMD_LOG  true
#define HOLDING(%0)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
new bool:Intentar[MAX_PLAYERS];
new MotorAuto[MAX_VEHICLES];
new bool:Spectador[MAX_PLAYERS];
new Hora, Minuto;
new AntiFloodZ[MAX_PLAYERS];
new TiempoAfk[MAX_PLAYERS];
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* ---===[- TEXTDRAWS -]===--- */
new Text:Textdraw0;
new Text:Textdraw1;
new Text:Textdraw2;
new Text:Textdraw3;
new Text:Textdraw4;
new Text:Textdraw5;
new Text:Textdraw6;
new Text:Textdraw7;
new Text:Textdraw8;
new Text:Textdraw9;
new Text:Textdraw10;
new Text:Textdraw11;
new Text:Textdraw12;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* ---===[- COLORES -]===--- */
new AdminsRangosColors[9] =
{
	0x80FFFFFF,
	0x00FF00FF,
	0x0080FFFF,
	0x800040FF,
	0xFF0000FF,
	0x400000FF,
	0x000000FF,
};
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* ---===[- Variables & Arrays -]===--- */
enum PlayerData
{
	Admin, //1 - 7
	Vip, //0 - No, 1 - Si
	Password[MAX_TEXTOS_CORTOS], //Long - 30
	Float:Pos[4], // X, Y, Z, VW
	Float:Vida, //80 - Max
	Float:Chaleco, //80 - Max
	Nivel, //Inicial - 1
	Experiencia, //Inicial - 0
	ExperienciaRe, //Experiencia requerida Nivel+4
	Faccion, //0 - 7 DESACTIVADO ACTUAL.
	Rango, //1 - 6 DESACTIVADO ACTUAL.
	Interior, //VW
	Skin, //31-Mujer, 35-Hombre
	Acento, //En Proceso.
	Dinero, //Inicial - 1200
	World, //0
	Armas[13], //Proceso...
	Municiones[13], //Proceso...
	AdminOn, // 1-Activado , 0-Desactivado
	Ciudad, //1-Los Santos[x], 2-San Fierro, 3-Las Venturas[x]
	Sexo, //1-Mujer, 2-Hombre
	Relacion[MAX_TEXTOS_LARGOS], //Casado con:_
	Estado, //0-Soltero, 1-Casado
	Edad, // >18, <80
	Baneado, //0-No, 1-Sí
	Warn //Inicial - 0
};
enum PlayersOnline
{
	Mundo,
	Armado,
	Muerto,
	MuertoEx
};
new PlayersData[MAX_PLAYERS][PlayerData],
	PlayersDataOnline[MAX_PLAYERS][PlayersOnline],
	bool:Logueado[MAX_PLAYERS],
	KickReason[MAX_PLAYERS],
//	Sonido[MAX_PLAYERS],
	IntentosLoguear[MAX_PLAYERS]  = MAX_INTENTOS,
	DIR_CUENTAS[MAX_GUARDADO]    = "/Usuarios/";
new COLOR_MESSAGES[5] =
{
    0x93A6FFFF,      // 0 - COLOR ERROR
    0xFFFFFFFF,      // 1 - COLOR AYUDA
    0x7D7D80F6,      // 2 - COLOR INFORMACIÓN
    0x0088F6F6,      // 3 - COLOR AFIRMATIVO
    0xFFFFFFFF       // 4 - Entorno
};
/* ---===[- Funciones & Demas -]===--- */
stock SendClientMessageEx(playerid, color, const text[], {Float, _}:...)
{
	static
	    args,
	    str[144];

	if ((args = numargs()) == 3)
	{
	    SendClientMessage(playerid, color, text);
	}
	else
	{
		while (--args >= 3)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit PUSH.S 8
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		SendClientMessage(playerid, color, str);

		#emit RETN
	}
	return 1;
}
stock SendClientMessageToAllEx(color, const text[], {Float, _}:...)
{
	static
	    args,
	    str[144];

	if ((args = numargs()) == 2)
	{
	    SendClientMessageToAll(color, text);
	}
	else
	{
		while (--args >= 2)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		SendClientMessageToAll(color, str);

		#emit RETN
	}
	return 1;
}
stock SendClientMessageX(color, const str[], {Float,_}:...)
{
	static
	    args,
	    start,
	    end,
	    string[144]
	;
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 8)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

	    for (end = start + (args - 8); end > start; end -= 4)
		{
	        #emit LREF.pri end
	        #emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

        foreach (new i : Player)
		{
			if (PlayersData[i][Admin] >= 1) {
  				SendClientMessage(i, color, string);
			}
		}
		return 1;
	}
	foreach (new i : Player)
	{
		if (PlayersData[i][Admin] >= 1) {
			SendClientMessage(i, color, str);
		}
	}
	return 1;
}
main()
{
	print("       ____________________________");
	print("      |- American RolePlay Server -|");
	print("      |    Scripted by JG-Studio   |");
	print("      |    Copyright © 2016-2017   |");
	print("      |        Version: 1.1.8      |");
	print("      |____________________________|");
}
stock PlayerName(playerid)
{
    new PlayerNameEx[MAX_PLAYER_NAME];
	GetPlayerName(playerid, PlayerNameEx, MAX_PLAYER_NAME);
	return PlayerNameEx;
}
stock RemoveUnderScore(playerid)
{
    new name[MAX_PLAYER_NAME];
    GetPlayerName(playerid,name,sizeof(name));
    for(new i = 0; i < MAX_PLAYER_NAME; i++)
    {
        if(name[i] == '_') name[i] = ' ';
    }
    return name;
}
stock CargarHora()
{
	gettime(Hora, Minuto);
	SetWorldTime(Hora);
	for(new i; i < GetMaxPlayers(); i++)
	{
		if(IsPlayerConnected(i) && GetPlayerState(i) != PLAYER_STATE_NONE)
		{
			SetPlayerTime(i,Hora,Minuto);
		}
	}
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* ---===[- FACCIONES -]===--- */
/* ---===[-FIN FACCIONES-]===---*/
stock GetPlayerAccount(playerid)
{
	new PlayerAccount[MAX_PLAYER_ACCOUNT_DATA];
	format(PlayerAccount, sizeof(PlayerAccount), "%s%s.ini", DIR_CUENTAS, PlayerName(playerid));
	return PlayerAccount;
}
forward ShowLoginOrRegister(playerid);
forward OnPlayerDeathEx(playerid);
forward SendInfoMessage(playerid, type, optional[], message[]);
forward ResetPlayerWeaponsEx(playerid);
forward SpawnRegisterOrLogin(playerid);
forward YSI_Save_Account(playerid);
forward CheckPlayerPassword(playerid, password[]);
forward GetPlayerPass(playerid, name[], password[]);
forward SetPlayerHealthEx(playerid, Float: vida);
forward SetPlayerArmourEx(playerid, Float: chaleco);
forward SetPlayerPosEx(playerid, Float: Pos_X, Float: Pos_Y, Float: Pos_Z);
forward YSI_Load_Account(playerid, name[], value[]);
forward RemoverMapeos(playerid);
forward CargarMapeos();
forward EncenderMotor(playerid);
forward ApagarMotor(playerid);
forward IntentarTimer(playerid);
forward PayDay(playerid);
forward AntiFlood(playerid);
forward Clock(playerid);

public Clock(playerid)
{
	new string[256];
	new hour, minute, second;
 	gettime(hour,minute,second);
    format(string, sizeof(string), "%d:%d:%d", hour, minute, second);
	TextDrawSetString(Text:Textdraw9, string);
	if (minute == 59)
	{
	    PayDay(playerid);
	}
}

public AntiFlood(playerid)
    {
    	AntiFloodZ[playerid] = 0;
    }
public IntentarTimer(playerid)
{
    if(IsPlayerConnected(playerid)) Intentar[playerid] = true;
    return 1;
}
forward DetectorCercania(Float:DistaciaRadio, playerid, stringg[],coll1,coll2,coll3,coll4,coll5);
public DetectorCercania(Float:DistaciaRadio, playerid, stringg[],coll1,coll2,coll3,coll4,coll5)
{
    if(IsPlayerConnected(playerid))
    {
        new Float:posx, Float:posy, Float:posz;
        new Float:oldposx, Float:oldposy, Float:oldposz;
        new Float:tempposx, Float:tempposy, Float:tempposz;
        GetPlayerPos(playerid, oldposx, oldposy, oldposz);
        for(new i = 0; i < MAX_PLAYERS; i++)
        {
            if(IsPlayerConnected(i) && (GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i)))
            {
                GetPlayerPos(i, posx, posy, posz);
                tempposx = (oldposx -posx);
                tempposy = (oldposy -posy);
                tempposz = (oldposz -posz);
                if (((tempposx < DistaciaRadio/16) && (tempposx > -DistaciaRadio/16)) && ((tempposy < DistaciaRadio/16) && (tempposy > -DistaciaRadio/16)) && ((tempposz < DistaciaRadio/16) && (tempposz > -DistaciaRadio/16)))
                {
                    SendClientMessage(i, coll1, stringg);
                }
                else if (((tempposx < DistaciaRadio/8) && (tempposx > -DistaciaRadio/8)) && ((tempposy < DistaciaRadio/8) && (tempposy > -DistaciaRadio/8)) && ((tempposz < DistaciaRadio/8) && (tempposz > -DistaciaRadio/8)))
                {
                    SendClientMessage(i, coll2, stringg);
                }
                else if (((tempposx < DistaciaRadio/4) && (tempposx > -DistaciaRadio/4)) && ((tempposy < DistaciaRadio/4) && (tempposy > -DistaciaRadio/4)) && ((tempposz < DistaciaRadio/4) && (tempposz > -DistaciaRadio/4)))
                {
                    SendClientMessage(i, coll3, stringg);
                }
                else if (((tempposx < DistaciaRadio/2) && (tempposx > -DistaciaRadio/2)) && ((tempposy < DistaciaRadio/2) && (tempposy > -DistaciaRadio/2)) && ((tempposz < DistaciaRadio/2) && (tempposz > -DistaciaRadio/2)))
                {
                    SendClientMessage(i, coll4, stringg);
                }
                else if (((tempposx < DistaciaRadio) && (tempposx > -DistaciaRadio)) && ((tempposy < DistaciaRadio) && (tempposy > -DistaciaRadio)) && ((tempposz < DistaciaRadio) && (tempposz > -DistaciaRadio)))
                {
                    SendClientMessage(i, coll5, stringg);
                }
            }
        }
    }
    return 1;
}
forward ProxDetectorS(Float:radi, playerid, targetid);
public ProxDetectorS(Float:radi, playerid, targetid)
{
    new
        Float: fp_playerPos[3];
    GetPlayerPos(targetid, fp_playerPos[0], fp_playerPos[1], fp_playerPos[2]);
    if(IsPlayerInRangeOfPoint(playerid, radi, fp_playerPos[0], fp_playerPos[1], fp_playerPos[2]) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(targetid))
    {
        return 1;
    }
    return 0;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public ShowLoginOrRegister(playerid)
{
    if ( PlayersDataOnline[playerid][Mundo] == 0 )
    {
        for( new i = 0; i <= 100; i ++ ) SendClientMessage(playerid, -1, " " );

        SetPlayerCameraPos(playerid, -2583.0808, 2311.5027, 53.9472);
        SetPlayerCameraLookAt(playerid, -2582.1450, 2311.8655, 53.5172);
        SendClientMessageEx(playerid, -1, Server_Logo);
		new PlayerAccount[MAX_PLAYER_ACCOUNT_DATA];
		format(PlayerAccount, sizeof(PlayerAccount), "%s%s.ini", DIR_CUENTAS, PlayerName(playerid));
	    if(fexist(PlayerAccount))
        {
            ShowPlayerDialog(playerid, DIALOG_LOGUEO, DIALOG_STYLE_PASSWORD, "Panel » {005EF6}Logueo", "{FFFFFF}Bienvenido nuevamente\n\n{FFFFFF}Por favor ingrese su contraseña para ingresar en {484EFA}American{FFFFFF} Role{FFFF00}Play", "Loguear", "");
        }
        else // Registro
        {
            ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD, "Panel » {005EF6}Registro", "{FFFFFF}Bienvenido a la comunidad de {484EFA}American{FFFFFF} Role{FFFF00}Play\n\n\t{FFFFFF}Por favor ingrese una contraseña & presione 'Continuar'", "Continuar", "");
        }
	}
	return 1;
}
public SpawnRegisterOrLogin(playerid)
{
    SetPlayerColor(playerid,-1);
    if ( PlayersDataOnline[playerid][Mundo] == 1 ) // Variables qué dara cuando logue por primera vez al servidor
    {
        for( new i = 0; i <= 100; i ++ ) SendClientMessage(playerid, -1, " " );
        SendInfoMessage(playerid, 4, "0", "Bienvenido a la hermosa Ciudad de San Fierro.");
        SendInfoMessage(playerid, 2, "0", "Recuerda utilizar el comando /Informacion para obtener consejos sobre tus primeros pasos.");
        SetPlayerHealth(playerid, MAX_PLAYER_VIDA);
        if( PlayersData[playerid][Sexo] == 1 )
        {
		    SetPlayerSkin(playerid, 31);
		    PlayersData[playerid][Skin] = GetPlayerSkin(playerid);
		    SendInfoMessage(playerid, 3, "0", "Bienvenida a la comunidad, por favor disfruta de ella!");
        }
        else
        {
            SetPlayerSkin(playerid, 35);
            PlayersData[playerid][Skin] = GetPlayerSkin(playerid);
            SendInfoMessage(playerid, 3, "0", "Bienvenido a la comunidad, por favor disfruta de ella!");
        }
        SetSpawnInfo(playerid, NO_TEAM, PlayersData[playerid][Skin], -2050.9604,462.0917,35.1719,312.4507,0,0,0,0,0,0);
        SetPlayerPos(playerid, -2050.9604,462.0917,35.1719);
        SetPlayerFacingAngle(playerid, 226.6042);
        YSI_Save_Account(playerid);
        PlayersDataOnline[playerid][Mundo] = 3;
        return 1;
    }
    if ( PlayersDataOnline[playerid][Mundo] == 2 ) // Variables qué dara cuando cargue la cuenta
    {
        for( new i = 0; i <= 100; i ++ ) SendClientMessage(playerid, -1, " " );
	    SetSpawnInfo(playerid, NO_TEAM, PlayersData[playerid][Skin], PlayersData[playerid][Pos][0], PlayersData[playerid][Pos][1], PlayersData[playerid][Pos][2], 10.0, -1, -1, -1, -1, -1, -1);
	    SetPlayerPosEx(playerid, PlayersData[playerid][Pos][0], PlayersData[playerid][Pos][1], PlayersData[playerid][Pos][2]);
		SetPlayerHealthEx(playerid, PlayersData[playerid][Vida]);
		SetPlayerSkin(playerid, PlayersData[playerid][Skin]);
		GivePlayerMoney(playerid, PlayersData[playerid][Dinero]);
  		SetPlayerScore(playerid, PlayersData[playerid][Nivel]);
	    TogglePlayerSpectating(playerid, false);
	    SendClientMessageEx(playerid, -1, "Bienvenido nuevamente a la comunidad de {484EFA}American{FFFFFF} Role{FFFF00}Play!, {FFFFFF}%s", RemoveUnderScore(playerid));
		new HiMsg[45];
		format(HiMsg, sizeof(HiMsg), "~W~Buenas!~N~~B~%s", RemoveUnderScore(playerid));
		GameTextForPlayer(playerid, HiMsg, 1000, 1);
        PlayersDataOnline[playerid][Mundo] = 3;
        return 1;
    }
	return 1;
}
public OnPlayerDeathEx(playerid)
{
    if ( PlayersDataOnline[playerid][Muerto] == 1 )
    {
        SendInfoMessage(playerid, 2, 	"0", "El hospital te ha costado $200");
		GivePlayerMoney(playerid, -100);
        SetPlayerHealth(playerid, MAX_PLAYER_VIDA);
        ResetPlayerWeaponsEx(playerid);
        SetPlayerSkin(playerid, PlayersData[playerid][Skin]);
        SetPlayerPos(playerid, -2050.9614,462.0909,35.1719);
        SetPlayerFacingAngle(playerid, 90.0966);
        TogglePlayerControllable(playerid, 1);
        TogglePlayerSpectating(playerid, 0);
        PlayersDataOnline[playerid][Muerto] = 0;
		SetPlayerColor(playerid, 0xFFFFFFF);
    }
	return 1;
}
public ResetPlayerWeaponsEx(playerid)
{
	for (new i = 0; i < 13; i++)
	{
		PlayersData[playerid][Armas][i]	     = 0;
		PlayersData[playerid][Municiones][i] = 0;
	}
	ResetPlayerWeapons(playerid);
}
public OnPlayerConnect(playerid)
{
    RemoverMapeos(playerid);
	Spectador[playerid] = false;
    PlayersDataOnline[playerid][Mundo] = 0;
    Intentar[playerid] = true;
    SetPlayerScore(playerid, PlayersData[playerid][Nivel]);
    gettime(Hora, Minuto);
    SetPlayerTime(playerid,Hora,Minuto);
    SetPlayerColor(playerid, 0x454545FF);
    TiempoAfk[playerid] = 0;
    TextDrawShowForPlayer(playerid, Textdraw0);
    TextDrawShowForPlayer(playerid, Textdraw1);
    TextDrawShowForPlayer(playerid, Textdraw2);
    TextDrawShowForPlayer(playerid, Textdraw3);
    TextDrawShowForPlayer(playerid, Textdraw4);
    TextDrawShowForPlayer(playerid, Textdraw5);
    TextDrawShowForPlayer(playerid, Textdraw6);
    TextDrawShowForPlayer(playerid, Textdraw7);
    TextDrawShowForPlayer(playerid, Textdraw8);
    TextDrawShowForPlayer(playerid, Textdraw10);
    TextDrawShowForPlayer(playerid, Textdraw11);
    TextDrawShowForPlayer(playerid, Textdraw12);
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
    SetSpawnInfo(playerid, 0, 26, 1742.9600, -1861.4019, 13.5776, 52.1403, 0, 0, 0, 0, 0, 0);
    SetTimerEx("ShowLoginOrRegister", 100, 0, "i", playerid);
	return 1;
}
public OnPlayerSpawn(playerid)
{
	if (PlayersData[playerid][Vip]==1)
	{
 	SetPlayerColor(playerid, 0xF1D50EFF);
	}
	else
	{
	SetPlayerColor(playerid, 0xFFFFFFFF);
	}
	if (PlayersData[playerid][AdminOn] == 1)
	{
	    PlayersData[playerid][AdminOn] = 0;
	    SendClientMessage(playerid, -1, "{A7A7A7}Te quedaste AdminOn al desconectar. Ten cuidado la próxima.");
	}
    OnPlayerDeathEx(playerid);
    SpawnRegisterOrLogin(playerid);
    gettime(Hora, Minuto);
    SetPlayerTime(playerid,Hora,Minuto);
    TextDrawHideForPlayer(playerid, Textdraw0);
    TextDrawHideForPlayer(playerid, Textdraw1);
    TextDrawHideForPlayer(playerid, Textdraw2);
    TextDrawHideForPlayer(playerid, Textdraw3);
    TextDrawHideForPlayer(playerid, Textdraw4);
    TextDrawHideForPlayer(playerid, Textdraw8);
    TextDrawShowForPlayer(playerid, Textdraw9);
    TextDrawHideForPlayer(playerid, Textdraw10);
    TextDrawHideForPlayer(playerid, Textdraw11);
    TextDrawHideForPlayer(playerid, Textdraw12);
	return 1;
}
public OnPlayerDisconnect(playerid, reason)
{
	YSI_Save_Account(playerid);
 	new text[180];
  	format(text, 180, "%s %s se ha desconectado del Servidor.", AdminMsg, RemoveUnderScore(playerid));
    DetectorCercania(15.0, playerid, text, 0xE6E6E6E6,0xC8C8C8C8,0xAAAAAAAA,0x8C8C8C8C,0x6E6E6E6E);
	return 1;
}
public OnPlayerDeath(playerid, killerid, reason)
{
    PlayersDataOnline[playerid][Muerto] = 1;
	return 1;
}
public OnPlayerText(playerid, text[])
{
    new string[160];
    format(string, sizeof(string), "%s dice: %s", RemoveUnderScore(playerid), text);
    DetectorCercania(7.0, playerid, string, 0xE6E6E6E6,0xC8C8C8C8,0xAAAAAAAA,0x8C8C8C8C,0x6E6E6E6E);
    SetPlayerChatBubble(playerid, text, -1, 7.0, 15000);
    return 0;
}
public OnPlayerUpdate(playerid)
{
	return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	new IDAuto = GetPlayerVehicleID(playerid);
	if(newkeys == KEY_FIRE)
	{
		if(IsPlayerInAnyVehicle(playerid))
		{
		if(AntiFloodZ[playerid] == 1) return SendClientMessageEx(playerid, -1, "%sEspera 5 segundos", InfoMsg);
		if(MotorAuto[IDAuto] == 0)
		{
			SetTimerEx("EncenderMotor", 500, false, "d", playerid);
			GameTextForPlayer(playerid, "~w~Encendiendo...",2000,3);
			new string[128 + MAX_PLAYER_NAME];
			format(string, sizeof(string), "*%s inserta la llave en el switch y la gira levemente!", RemoveUnderScore(playerid));
			DetectorCercania(30.0, playerid, string, 0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA);
		}
		else
		{
			SetTimerEx("ApagarMotor", 500, false, "d", playerid);
			GameTextForPlayer(playerid, "~w~Apagando...",1000,3);
			new string[128 + MAX_PLAYER_NAME];
			format(string, sizeof(string), "*%s gira la llave del switch!", RemoveUnderScore(playerid));
			DetectorCercania(30.0, playerid, string, 0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA);
		}
		}
		return 1;
		}
	return 1;
}
public EncenderMotor(playerid)
    {
            new IDAuto = GetPlayerVehicleID(playerid);
            new enginem, lights, alarm, doors, bonnet, boot, objective;
            GetVehicleParamsEx(GetPlayerVehicleID(playerid),enginem, lights, alarm, doors, bonnet, boot, objective);
            SetVehicleParamsEx(GetPlayerVehicleID(playerid),VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);
            GameTextForPlayer(playerid, "~w~Motor ~g~Encendido",1000,3);
            MotorAuto[IDAuto] = 1;
            new string[128 + MAX_PLAYER_NAME];
            format(string, sizeof(string), "**Vehículo encendido [ID:%d]", playerid);
            DetectorCercania(30.0, playerid, string, 0xFFFF00FF,0xFFFF00FF,0xFFFF00FF,0xFFFF00FF,0xFFFF00FF);
            AntiFloodZ[playerid] = 1;
            SetTimerEx("AntiFlood", 5000, false, "d", playerid);
    }
public ApagarMotor(playerid)
    {
        new IDAuto = GetPlayerVehicleID(playerid);
        new enginem, lights, alarm, doors, bonnet, boot, objective;
        GetVehicleParamsEx(GetPlayerVehicleID(playerid),enginem, lights, alarm, doors, bonnet, boot, objective);
        SetVehicleParamsEx(GetPlayerVehicleID(playerid),VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);
        GameTextForPlayer(playerid, "~w~Motor ~r~Apagado",1000,3);
        MotorAuto[IDAuto] = 0;
        new string[128 + MAX_PLAYER_NAME];
        format(string, sizeof(string), "**Vehículo apagado [ID:%d]", playerid);
        DetectorCercania(30.0, playerid, string, 0xFFFF00FF,0xFFFF00FF,0xFFFF00FF,0xFFFF00FF,0xFFFF00FF);
        AntiFloodZ[playerid] = 1;
        SetTimerEx("AntiFlood", 5000, false, "d", playerid);
    }
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}
public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if (GetPlayerVehicleSeat(playerid)==1){
	if(MotorAuto[vehicleid] == 0)
	{
		SendClientMessageEx(playerid, -1,"%sEste coche está apagado! presiona Alt para encenderlo.", InfoMsg);
	}
	else if(MotorAuto[vehicleid] == 1)
	{
		SendClientMessageEx(playerid,-1,"%sEste coche está encendido! presiona Alt para apagarlo.", InfoMsg);
	}
	}
 	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
    return 1;
}
public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}
public GetPlayerPass(playerid, name[], password[])
{
	if(strcmpEx(name, "Password")) SetPVarString(playerid, "PlayerPassword", password);
}

public CheckPlayerPassword(playerid, password[])
{
	new PlayerAccount[MAX_PLAYER_ACCOUNT_DATA], PlayerPass[MAX_TEXTOS_CORTOS];
	format(PlayerAccount, sizeof(PlayerAccount), "%s%s.ini", DIR_CUENTAS, PlayerName(playerid));
	INI_ParseFile(PlayerAccount, "GetPlayerPass", .bExtra = true,  .extra = playerid);
	GetPVarString(playerid, "PlayerPassword", PlayerPass, MAX_TEXTOS_CORTOS);
	if(strcmpEx(PlayerPass, password) && strlen(PlayerPass) == strlen(password))
	{
	    if(PlayersData[playerid][Baneado])
		{
		    SendInfoMessage(playerid, 0, "1", "Tu cuenta se encuentra baneada, visite www.test.net");
      		Kick(playerid);
		    return 1;
		}
		format(PlayerAccount, sizeof(PlayerAccount), "%s%s.ini", DIR_CUENTAS, PlayerName(playerid));
        INI_ParseFile(PlayerAccount, "YSI_Load_Account", false, true, playerid, true, false);
        KillTimer(Logueado[playerid]);
        Logueado[playerid] = true;
        PlayersDataOnline[playerid][Mundo] = 2;
        SpawnPlayer(playerid);
  		return 1;
	}
	else
	{
	    new MsgPlayerPassword[MAX_TEXT_CHAT]; IntentosLoguear[playerid] --;
		SendInfoMessage(playerid, 0, "1", "La contraseña introducída es incorrecta");
	    format(MsgPlayerPassword, sizeof(MsgPlayerPassword), "{005EF6}%s{FFFFFF}, esa Contraseña es Incorrecta. Aún tienes {FF0000}%d {FFFFFF}intentos, si no la Recuerda\nSerás kickeado del Servidor.", PlayerName(playerid), IntentosLoguear[playerid]);
		ShowPlayerDialog(playerid, DIALOG_LOGUEO, DIALOG_STYLE_PASSWORD, "{484EFA}American{FFFFFF} Role{FFFF00}Play » Loguear", MsgPlayerPassword, "Loguear", "");
	    if(IntentosLoguear[playerid] <= 0)
	    {
            SendInfoMessage(playerid, 0, "3", "Has superado los intentos de conexión, fuiste expulsado");
            Kick(playerid);
		}
	}
	return 1;
}
public OnPlayerCommandPerformed(playerid, cmdtext[], success)
{
	#if CMD_LOG == true
	if(success)
	{
		printf("[COMANDO_LOG] %s: %s",PlayerName(playerid),cmdtext);
	}
	#endif
	if(Logueado[playerid] == false)
	{
        SendInfoMessage(playerid, 0, "3", "Has sido silenciado o no has conectado al servidor, para usar comandos");
        return 0;
	}
    if(!success)
	{
	    new string[260];
	    format(string,256,"El comando {005EF6}({FFFFFF}%s{005EF6}){FFFFFF} es inválido, Por favor, use '{005EF6}/Ayuda{FFFFFF}'",cmdtext);
	    SendClientMessage(playerid, -1, string);
	}
	return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
 	switch (dialogid)
	 {
        case DIALOG_REGISTRO:
		{
            new MsgConnection[MAX_TEXT_CHAT+5];
		    if(response)
		    {
			    if(strlen(inputtext) < MIN_ACCOUNT_CHAR)
   			    {
      			    format(MsgConnection, sizeof(MsgConnection), "{FFFFFF} La Contraseña introducída tiene menos de %i Carácteres.\nEscribe una contraseña que supere o iguale los %i Carácteres.", MIN_ACCOUNT_CHAR, MIN_ACCOUNT_CHAR, PlayerName(playerid));
				    ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD, "{484EFA}American{FFFFFF} Role{FFFF00}Play{FFFFFF} » Registro", MsgConnection, "Continuar", "");
				    return 1;
			    }
   			    Logueado[playerid] = true;
			    PlayersData[playerid][Nivel] 	= PLAYER_START_LEVEL;
			    SetPlayerScore(playerid, PlayersData[playerid][Nivel]);
			    PlayersData[playerid][Dinero]   = PLAYER_START_MONEY;
			    PlayersData[playerid][Estado]   =   0;
			    PlayersData[playerid][ExperienciaRe]    =   4;
			    strmid(PlayersData[playerid][Password], inputtext, 0, strlen(inputtext), 255);
		        format(MsgConnection, sizeof(MsgConnection), "{FFFFFF}Bien, ahora escriba la edad que tendrá su personaje.");
			    ShowPlayerDialog(playerid, DIALOG_EDAD, DIALOG_STYLE_INPUT, "{005EF6}Registro{FFFFFF} » Edad", MsgConnection, "Continuar", "");
			    KickReason[playerid] = false;
		    }
		    else
		    {
  			    format(MsgConnection, sizeof(MsgConnection), "{FFFFFF}Bienvenido a la comunidad de {484EFA}American{FFFFFF} Role{FFFF00}Play\n\n\tPor favor ingrese una contraseña & presione 'Continuar'", PlayerName(playerid));
			    ShowPlayerDialog(playerid, DIALOG_REGISTRO, DIALOG_STYLE_PASSWORD, "{005EF6}Panel{FFFFFF} » Registro", MsgConnection, "Continuar", "");
		    }

		}
		case DIALOG_LOGUEO:
		{
            new MsgConnection[MAX_TEXT_CHAT];
            if(response)
		    {
		        if(strlen(inputtext))
			    {
       			    CheckPlayerPassword(playerid, inputtext);
       			    return 1;
			    }
			    else
			    {
			        format(MsgConnection, sizeof(MsgConnection), "{FFFFFF}Bienvenido nuevamente %s\n\n\t{FFFFFF}Por favor ingrese su contraseña para ingresar en {484EFA}American{FFFFFF} Role{FFFF00}Play", RemoveUnderScore(playerid));
				    ShowPlayerDialog(playerid, DIALOG_LOGUEO, DIALOG_STYLE_PASSWORD, "Panel » {005EF6}Logueo", MsgConnection, "Loguear", "");
			    }
		    }
		    else
		    {
		        format(MsgConnection, sizeof(MsgConnection), "{FFFFFF}Bienvenido nuevamente %s\n\n\t{FFFFFF}Por favor ingrese su contraseña para ingresar en {484EFA}American{FFFFFF} Role{FFFF00}Play", RemoveUnderScore(playerid));
			    ShowPlayerDialog(playerid, DIALOG_LOGUEO, DIALOG_STYLE_PASSWORD, "Panel » {005EF6}Logueo", MsgConnection, "Loguear", "");
		    }
		}
		case DIALOG_EDAD:
		{
            new MsgAgeText[MAX_TEXT_CHAT];
		    if(response)
		    {
		        if(strlen(inputtext))
			    {
			        if(strval(inputtext) < 18 || strval(inputtext) > 80) { ShowPlayerDialog(playerid, DIALOG_EDAD, DIALOG_STYLE_INPUT, "{005EF6}Registro » Selecciona Edad:", "{FFFFFF}¡La Edad debe ser entre {005EF6}18 {FFFFFF}y {005EF6}80{FFFFFF}!", "Continuar", ""); return 1; }
			        format(MsgAgeText, sizeof(MsgAgeText), "{484EFA}American{FFFFFF} Role{FFFF00}Play {FFFFFF}» Okey, así que tendrás {8C8C8C}%i {FFFFFF}Años.", strval(inputtext));
			        SendClientMessage(playerid, -1, MsgAgeText);
				    PlayersData[playerid][Edad] = strval(inputtext);
				    format(MsgAgeText, sizeof(MsgAgeText), \
				    "\nLos Santos." \
				    "\nSan Fierro." \
				    "\nLas Venturas.");
				    ShowPlayerDialog(playerid, DIALOG_CIUDAD, DIALOG_STYLE_LIST, "{005EF6}Registro{FFFFFF} » Origen", MsgAgeText, "Continuar", "");
				    return 1;
			    }
			    else
			    {
			        format(MsgAgeText, sizeof(MsgAgeText), "{FFFFFF}Escribe la Edad que Tendrá tu Personaje en el Server.", RemoveUnderScore(playerid));
				    ShowPlayerDialog(playerid, DIALOG_EDAD, DIALOG_STYLE_INPUT, "{005EF6}Registro{FFFFFF} » Edad", MsgAgeText, "Continuar", "");
				    return 1;
			    }
		    }
		    else
		    {
  			    format(MsgAgeText, sizeof(MsgAgeText), "{FFFFFF}Escribe la Edad que Tendrá tu Personaje en el Server.", RemoveUnderScore(playerid));
			    ShowPlayerDialog(playerid, DIALOG_EDAD, DIALOG_STYLE_INPUT, "{005EF6}Registro{FFFFFF} » Edad", MsgAgeText, "Continuar", "");
			    return 1;
		    }
		}
		case DIALOG_CIUDAD:
		{
	        if(response)
	        {
	            switch(listitem)
	            {
	                case 0:
		            {
		                new MsgCityText[MAX_TEXT_CHAT-100];
		                SendInfoMessage(playerid, 0, "2", "Esa no es una opción");
		                format(MsgCityText, sizeof(MsgCityText), \
					    "\nLos Santos." \
					    "\nSan Fierro." \
					    "\nLas Venturas.");
					    ShowPlayerDialog(playerid, DIALOG_CIUDAD, DIALOG_STYLE_LIST, "{005EF6}Registro » Origen", MsgCityText, "Continuar", "");
					    return 1;
				    }
				    case 1:
				    {
				        new MsgCityText[MAX_TEXT_CHAT];
				        PlayersData[playerid][Ciudad] = 1;
				        format(MsgCityText, sizeof(MsgCityText), "{484EFA}American{FFFFFF} Role{FFFF00}Play {FFFFFF}» Bien ahora sabemos tu ciudad natal, viviras en {8C8C8C}Los Santos{FFFFFF}.");
						return 1;
					}
					case 2:
					{
				        new MsgCityText[MAX_TEXT_CHAT];
				        PlayersData[playerid][Ciudad] = 2;
				        format(MsgCityText, sizeof(MsgCityText), "{484EFA}American{FFFFFF} Role{FFFF00}Play {FFFFFF}» Bien ahora sabemos tu ciudad natal, viviras en {8C8C8C}San Fierro{FFFFFF}.");
						return 1;
					}
					case 3:
					{
				        new MsgCityText[MAX_TEXT_CHAT];
				        PlayersData[playerid][Ciudad] = 3;
				        format(MsgCityText, sizeof(MsgCityText), "{484EFA}American{FFFFFF} Role{FFFF00}Play {FFFFFF}» Bien ahora sabemos tu ciudad natal, viviras en {8C8C8C}Las Venturas{FFFFFF}.");
						return 1;
					}
					default:
				    {
				        new MsgCityText[MAX_TEXT_CHAT];
				        PlayersData[playerid][Ciudad] = 1;
				        format(MsgCityText, sizeof(MsgCityText), "{484EFA}American{FFFFFF} Role{FFFF00}Play {FFFFFF}» Bien ahora sabemos tu ciudad natal, viviras en {8C8C8C}San Fierro{FFFFFF}.");
					    ShowPlayerDialog(playerid, DIALOG_SEXO, DIALOG_STYLE_MSGBOX, "{005EF6}Registro{FFFFFF} » Sexo", "{FFFFFF}Bien, ahora por favor, seleccione su sexo...", "Masculino", "Femenino");
                        SendClientMessage(playerid, -1, MsgCityText);
                        //SeleccionGenero(playerid);
					    return 1;
				    }
			    }
		    }
		    else
		    {
				new string[MAX_TEXT_CHAT-100];
		        format(string, sizeof(string), \
			    "\nLos Santos." \
			    "\nSan Fierro." \
			    "\nLas Venturas.");
			    ShowPlayerDialog(playerid, DIALOG_CIUDAD, DIALOG_STYLE_LIST, "{005EF6}Registro{FFFFFF} » Origen", string, "Continuar", "");
			    return 1;
		    }
		}
		case DIALOG_SEXO:
		{
		    if(response)
			{
			    SendClientMessage(playerid, -1, "{484EFA}American{FFFFFF} Role{FFFF00}Play {FFFFFF}» Perfecto, con que usted es sexo {8C8C8C}Masculino{FFFFFF}.");
			    PlayersData[playerid][Sexo] = 2;
			    PlayersDataOnline[playerid][Mundo] = 1;
			    SpawnPlayer(playerid);
			    return 1;
			}
		    else
			{
			    SendClientMessage(playerid, -1, "{484EFA}American{FFFFFF} Role{FFFF00}Play {FFFFFF}» Perfecto, con que usted es sexo {8C8C8C}Femenino{FFFFFF}.");
			    PlayersData[playerid][Sexo] = 1;
			    PlayersDataOnline[playerid][Mundo] = 1;
			    SpawnPlayer(playerid);
			    return 1;
			}
		}
        case DIALOG_AYUDA:
        {
            if(!response)return 1;
            switch(listitem)
            {
                case 0:
                {
                    new MsgDialogGeneral[500];
                    format(MsgDialogGeneral, sizeof(MsgDialogGeneral),
                    "{FFFFFF}Ayuda General {005EF6}» {FFFFFF}American RolePlay\n {0080FF}/Entorno {FFFFFF}- {0080FF}/Reportar [ID] [Razón] {FFFFFF}-{0080FF} /Duda [Mensaje]");
                    ShowPlayerDialog(playerid, 999, DIALOG_STYLE_MSGBOX, "{00A5FF}Comandos Generales {FFFFFF}{484EFA}American{FFFFFF} Role{FFFF00}Play", MsgDialogGeneral, "Aceptar", "");
                    return 1;
                }
                case 1:
                {
                    new MsgDialogChat[500];
                    format(MsgDialogChat, sizeof(MsgDialogChat),
                    "{FFFFFF}Ayuda Chat {005EF6}»{FFFFFF}American RolePlay\n {0080FF}/me [Acción] {FFFFFF}- {0080FF}/ame [Entorno] {FFFFFF}- {0080FF}/intentar [Acción] {FFFFFF}- {0080FF}/g [Grito]\n {0080FF}/b [OOC]");
                    ShowPlayerDialog(playerid, 999, DIALOG_STYLE_MSGBOX, "{00A5FF}Comandos del Chat {484EFA}American{FFFFFF} Role{FFFF00}Play.", MsgDialogChat, "Aceptar", "");
                    return 1;
                }
                case 2:
                {
                    new MsgDialogCasa[500];
                    format(MsgDialogCasa, sizeof(MsgDialogCasa),
                    "{FFFFFF}Ayuda Casas {005EF6}»{FFFFFF}American RolePlay\n");
                    ShowPlayerDialog(playerid, 999, DIALOG_STYLE_MSGBOX, "{00A5FF}Comandos de las casas {484EFA}American{FFFFFF} Role{FFFF00}Play.", MsgDialogCasa, "Aceptar", "");
                    return 1;
                }
            }
        }
	}
	return 1;
}
public OnGameModeInit()
{
	SetGameModeText(Server_GameText);
	new rcon[80];
	format(rcon, sizeof(rcon), "hostname %s", Server_Nombre);
	SendRconCommand(rcon);
	format(rcon, sizeof(rcon), "weburl %s", Server_Web);
	SendRconCommand(rcon);
	format(rcon, sizeof(rcon), "mapname %s", Server_Map);
	SendRconCommand(rcon);
	format(rcon, sizeof(rcon), "language %s", Server_Language);
	SendRconCommand(rcon);
	format(rcon, sizeof(rcon), "password %s", Server_Password);
	SendRconCommand(rcon);
	format(rcon, sizeof(rcon), "rconpassword %s", Server_Rcon);
	SendRconCommand(rcon);
	////////////// LOADS
	CargarMapeos();
	DisableInteriorEnterExits();
    ManualVehicleEngineAndLights();
    EnableStuntBonusForAll(0);
    ShowPlayerMarkers(0);
    UsePlayerPedAnims();
    CargarHora();
    SetTimer("CargarHora",1000*60,1);
    SetTimer("Clock", 1000, 1);
    SetTimer("Check1s", 1000, 1);
    Textdraw9 = TextDrawCreate(551.000000,23.000000,"--");
    TextDrawAlignment(Textdraw9,0);
    TextDrawBackgroundColor(Textdraw9,0x000000FF);
    TextDrawLetterSize(Textdraw9,0.399999,2.000000);
    TextDrawColor(Textdraw9,0xFFFFFFFF);
    TextDrawSetOutline(Textdraw9,1);
    TextDrawSetProportional(Textdraw9,1);
    TextDrawSetShadow(Textdraw9,1);

	Textdraw0 = TextDrawCreate(657.000000, 1.499963, "usebox");
	TextDrawLetterSize(Textdraw0, 0.000000, 13.390736);
	TextDrawTextSize(Textdraw0, -2.000000, 0.000000);
	TextDrawAlignment(Textdraw0, 1);
	TextDrawColor(Textdraw0, 0);
	TextDrawUseBox(Textdraw0, true);
	TextDrawBoxColor(Textdraw0, 102);
	TextDrawSetShadow(Textdraw0, 0);
	TextDrawSetOutline(Textdraw0, 0);
	TextDrawFont(Textdraw0, 0);

	Textdraw1 = TextDrawCreate(831.500000, 352.433380, "usebox");
	TextDrawLetterSize(Textdraw1, 0.000000, 10.275923);
	TextDrawTextSize(Textdraw1, -9.500000, 0.000000);
	TextDrawAlignment(Textdraw1, 1);
	TextDrawColor(Textdraw1, 0);
	TextDrawUseBox(Textdraw1, true);
	TextDrawBoxColor(Textdraw1, 102);
	TextDrawSetShadow(Textdraw1, 0);
	TextDrawSetOutline(Textdraw1, 0);
	TextDrawFont(Textdraw1, 0);

	Textdraw2 = TextDrawCreate(659.000000, 347.455566, "usebox");
	TextDrawLetterSize(Textdraw2, 0.000000, 0.832095);
	TextDrawTextSize(Textdraw2, -10.500000, 0.000000);
	TextDrawAlignment(Textdraw2, 1);
	TextDrawColor(Textdraw2, 16777215);
	TextDrawUseBox(Textdraw2, true);
	TextDrawBoxColor(Textdraw2, 65535);
	TextDrawSetShadow(Textdraw2, 0);
	TextDrawSetOutline(Textdraw2, 0);
	TextDrawFont(Textdraw2, 0);

	Textdraw3 = TextDrawCreate(674.000000, 120.344444, "usebox");
	TextDrawLetterSize(Textdraw3, 0.000000, 0.789506);
	TextDrawTextSize(Textdraw3, -19.500000, 0.000000);
	TextDrawAlignment(Textdraw3, 1);
	TextDrawColor(Textdraw3, 0);
	TextDrawUseBox(Textdraw3, true);
	TextDrawBoxColor(Textdraw3, 65535);
	TextDrawSetShadow(Textdraw3, 0);
	TextDrawSetOutline(Textdraw3, 0);
	TextDrawFont(Textdraw3, 0);

	Textdraw4 = TextDrawCreate(39.000000, 9.333409, "Bienvenido");
	TextDrawLetterSize(Textdraw4, 0.624998, 3.279998);
	TextDrawAlignment(Textdraw4, 1);
	TextDrawColor(Textdraw4, -1);
	TextDrawSetShadow(Textdraw4, 5);
	TextDrawSetOutline(Textdraw4, 0);
	TextDrawBackgroundColor(Textdraw4, 51);
	TextDrawFont(Textdraw4, 1);
	TextDrawSetProportional(Textdraw4, 1);

	Textdraw5 = TextDrawCreate(38.418716, 425.249877, "GreatCity");
	TextDrawLetterSize(Textdraw5, 0.449999, 1.600000);
	TextDrawAlignment(Textdraw5, 2);
	TextDrawColor(Textdraw5, 0xFD0013FF);
	TextDrawSetShadow(Textdraw5, 2);
	TextDrawSetOutline(Textdraw5, 0);
	TextDrawBackgroundColor(Textdraw5, 51);
	TextDrawFont(Textdraw5, 1);
	TextDrawSetProportional(Textdraw5, 1);

	Textdraw6 = TextDrawCreate(79.648590, 425.249786, "Role");
	TextDrawLetterSize(Textdraw6, 0.449999, 1.600000);
	TextDrawAlignment(Textdraw6, 1);
	TextDrawColor(Textdraw6, -1);
	TextDrawSetShadow(Textdraw6, 2);
	TextDrawSetOutline(Textdraw6, 0);
	TextDrawBackgroundColor(Textdraw6, 51);
	TextDrawFont(Textdraw6, 1);
	TextDrawSetProportional(Textdraw6, 1);

	Textdraw7 = TextDrawCreate(112.445068, 425.833343, "Play");
	TextDrawLetterSize(Textdraw7, 0.449999, 1.600000);
	TextDrawAlignment(Textdraw7, 1);
	TextDrawColor(Textdraw7, 41215);
	TextDrawSetShadow(Textdraw7, 2);
	TextDrawSetOutline(Textdraw7, 0);
	TextDrawBackgroundColor(Textdraw7, 51);
	TextDrawFont(Textdraw7, 1);
	TextDrawSetProportional(Textdraw7, 1);

	Textdraw8 = TextDrawCreate(140.500000, 378.311096, "Una Nueva Aventura");
	TextDrawLetterSize(Textdraw8, 0.732999, 2.396445);
	TextDrawAlignment(Textdraw8, 1);
	TextDrawColor(Textdraw8, -2147483393);
	TextDrawSetShadow(Textdraw8, 4);
	TextDrawSetOutline(Textdraw8, 0);
	TextDrawBackgroundColor(Textdraw8, 51);
	TextDrawFont(Textdraw8, 2);
	TextDrawSetProportional(Textdraw8, 1);

	Textdraw10 = TextDrawCreate(150.500000, 36.711116, "American");
	TextDrawLetterSize(Textdraw10, 0.920000, 5.053334);
	TextDrawAlignment(Textdraw10, 1);
	TextDrawColor(Textdraw10, 41215);
	TextDrawSetShadow(Textdraw10, 3);
	TextDrawSetOutline(Textdraw10, 0);
	TextDrawBackgroundColor(Textdraw10, 51);
	TextDrawFont(Textdraw10, 1);
	TextDrawSetProportional(Textdraw10, 1);

	Textdraw11 = TextDrawCreate(300.000000, 60.977748, "Role");
	TextDrawLetterSize(Textdraw11, 0.824998, 4.462223);
	TextDrawAlignment(Textdraw11, 1);
	TextDrawColor(Textdraw11, -1);
	TextDrawSetShadow(Textdraw11, 5);
	TextDrawSetOutline(Textdraw11, 0);
	TextDrawBackgroundColor(Textdraw11, 51);
	TextDrawFont(Textdraw11, 1);
	TextDrawSetProportional(Textdraw11, 1);

	Textdraw12 = TextDrawCreate(361.500000, 60.355552, "Play");
	TextDrawLetterSize(Textdraw12, 0.779999, 4.711108);
	TextDrawAlignment(Textdraw12, 1);
	TextDrawColor(Textdraw12, -5963521);
	TextDrawSetShadow(Textdraw12, 2);
	TextDrawSetOutline(Textdraw12, 0);
	TextDrawBackgroundColor(Textdraw12, 51);
	TextDrawFont(Textdraw12, 1);
	TextDrawSetProportional(Textdraw12, 1);
	return 1;
}
public OnGameModeExit()
{
	return 1;
}
public RemoverMapeos(playerid)
{
    RemoveBuildingForPlayer(playerid, 1290, 1750.1094, 556.5469, 31.0391, 0.25);//PeajeLV
    RemoveBuildingForPlayer(playerid, 3852, -2614.9063, 686.3672, 28.3594, 0.25);//SFMD-Iglesia
	RemoveBuildingForPlayer(playerid, 9840, -2567.3438, 516.8281, 30.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 3876, -2573.2344, 487.3750, 46.7813, 0.25);
	RemoveBuildingForPlayer(playerid, 3876, -2559.6094, 487.3750, 46.7813, 0.25);
	RemoveBuildingForPlayer(playerid, 3876, -2542.3828, 506.9219, 46.7813, 0.25);
	RemoveBuildingForPlayer(playerid, 9885, -2633.9844, 586.9688, 38.3125, 0.25);
	RemoveBuildingForPlayer(playerid, 3877, -2565.9063, 480.2422, 49.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 1233, -2595.4531, 573.6875, 15.0703, 0.25);
	RemoveBuildingForPlayer(playerid, 9834, -2567.3438, 516.8281, 30.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 9897, -2567.3438, 516.8281, 30.6250, 0.25);
	RemoveBuildingForPlayer(playerid, 1233, -2556.4453, 557.9766, 15.0703, 0.25);//SFMD-Iglesia
	RemoveBuildingForPlayer(playerid, 10248, -1680.9922, 683.2344, 19.0469, 0.25);//SFPD
	RemoveBuildingForPlayer(playerid, 966, -1572.2031, 658.8359, 6.0781, 0.25);
	RemoveBuildingForPlayer(playerid, 967, -1572.7031, 657.6016, 6.0781, 0.25);//SFPD
	RemoveBuildingForPlayer(playerid, 1232, -2916.6172, 419.7344, 6.5000, 0.25);//Taller SF
	RemoveBuildingForPlayer(playerid, 1232, -2880.3828, 419.7344, 6.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, -2911.4219, 422.3516, 4.2891, 0.25);
	RemoveBuildingForPlayer(playerid, 1280, -2886.5859, 422.3516, 4.2891, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, -2993.8125, 457.8672, 6.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, -2961.8906, 484.0156, 6.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 1232, -2916.8984, 506.8203, 6.5000, 0.25);//Taller SF
	RemoveBuildingForPlayer(playerid, 1438, 872.2656, -1346.4141, 12.5313, 0.25);//Callejon Market
	RemoveBuildingForPlayer(playerid, 1411, 875.4141, -1343.6563, 14.0859, 0.25);//Callejon Market
    RemoveBuildingForPlayer(playerid, 3593, 2437.4844, -1644.1172, 12.9844, 0.25);//Groove
	return 1;
}
public CargarMapeos()
{
	CreateObject(19868, 2863.31567, -889.89563, 9.76510,   0.00000, 0.00000, 89.00000);//PeajeLV
	CreateObject(19868, 2863.40503, -884.68658, 9.76510,   0.00000, 0.00000, 89.00000);
	CreateObject(19868, 2863.50171, -879.50751, 9.76510,   0.00000, 0.00000, 89.00000);
	CreateObject(19868, 2863.58325, -874.34479, 9.76510,   0.00000, 0.00000, 89.00000);
	CreateObject(19868, 2863.67358, -869.16101, 9.76510,   0.00000, 0.00000, 89.00000);
	CreateObject(19868, 2863.75562, -863.98108, 9.76510,   0.00000, 0.00000, 89.00000);
	CreateObject(19868, 2863.84985, -858.80292, 9.76510,   0.00000, 0.00000, 89.00000);
	CreateObject(9623, 1741.99036, 530.44128, 29.11610,   -3.50000, 0.00000, -18.50000);
	CreateObject(1290, 1751.73682, 561.31049, 31.03906,   3.14159, 0.00000, 0.30842);
	CreateObject(3660, 1747.59753, 549.66809, 27.52960,   0.00000, 3.00000, 72.00000);
	CreateObject(3660, 1734.83557, 512.18341, 29.72960,   0.00000, 3.00000, 71.00000);
	CreateObject(966, 1730.93506, 527.86108, 26.83540,   0.00000, 0.00000, -20.00000);
	CreateObject(966, 1752.83362, 532.88855, 26.05540,   0.00000, 0.00000, 160.00000);
	CreateObject(966, 1739.34595, 525.00647, 26.79540,   0.00000, 0.00000, -20.00000);
	CreateObject(966, 1744.01672, 535.94348, 26.05540,   0.00000, 0.00000, 160.00000);
	CreateObject(968, 1744.02234, 535.94757, 26.64910,   0.00000, -90.00000, 160.00000);
	CreateObject(968, 1752.90076, 532.84888, 26.64910,   0.00000, -90.00000, 160.00000);
	CreateObject(968, 1730.90442, 527.86951, 27.41430,   0.00000, -90.00000, -20.00000);
	CreateObject(968, 1739.30493, 525.02393, 27.41430,   0.00000, -90.00000, -20.00000);
	CreateObject(3877, 1759.89429, 530.14465, 27.48180,   0.00000, 0.00000, 70.00000);
	CreateObject(3877, 1760.82947, 529.79053, 27.48180,   0.00000, 0.00000, 70.00000);
	CreateObject(3877, 1723.85461, 530.56537, 27.68180,   0.00000, 0.00000, 70.00000);
	CreateObject(3877, 1722.91516, 530.91626, 27.68180,   0.00000, 0.00000, 70.00000);
	CreateObject(3877, 1721.97668, 531.26764, 27.68180,   0.00000, 0.00000, 70.00000);
	CreateObject(7415, 1741.41943, 529.98767, 41.11110,   0.00000, 0.00000, 102.00000);
	CreateObject(7415, 1741.51428, 530.23676, 41.11110,   0.00000, 0.00000, -77.00000);//PeajeLV
	CreateObject(9897, -2656.42114, 666.78888, 15.48184,   0.00000, 0.00000, -45.06001);//SFMD-Iglesia
	CreateObject(19978, -2671.39380, 631.90082, 13.43797,   0.00000, 0.00000, 0.00000);
	CreateObject(11710, -2595.17993, 642.35663, 16.50150,   0.00000, 0.00000, 90.00000);
	CreateObject(19969, -2578.08643, 573.65387, 13.44100,   0.00000, 0.00000, 90.00000);
	CreateObject(969, -2562.38330, 581.27142, 13.44080,   0.00000, 0.00000, -180.00000);
	CreateObject(8674, -2576.30591, 581.25391, 14.93070,   0.00000, 0.00000, 0.00000);
	CreateObject(8674, -2586.60596, 581.25391, 14.93070,   0.00000, 0.00000, 0.00000);
	CreateObject(8674, -2591.74609, 581.25391, 14.93070,   0.00000, 0.00000, 0.00000);
	CreateObject(8674, -2557.08594, 581.25391, 14.93070,   0.00000, 0.00000, 0.00000);
	CreateObject(8674, -2546.80591, 581.25391, 14.93070,   0.00000, 0.00000, 0.00000);
	CreateObject(8674, -2543.16602, 581.25391, 14.93070,   0.00000, 0.00000, 0.00000);
	CreateObject(19868, -2596.65991, 583.85907, 13.44460,   0.00000, 0.00000, 90.00000);
	CreateObject(969, -2596.64136, 588.14069, 13.44080,   0.00000, 0.00000, 90.00000);
	CreateObject(19868, -2596.65991, 599.49908, 13.44460,   0.00000, 0.00000, 90.00000);
	CreateObject(19868, -2596.65991, 585.41913, 13.44460,   0.00000, 0.00000, 90.00000);
	CreateObject(19868, -2596.65698, 604.76727, 13.44460,   0.00000, 0.00000, 90.00000);
	CreateObject(19868, -2596.65698, 610.02728, 13.44460,   0.00000, 0.00000, 90.00000);
	CreateObject(19868, -2596.65698, 615.28729, 13.44460,   0.00000, 0.00000, 90.00000);
	CreateObject(9897, -2561.19214, 652.11481, 9.82900,   0.00000, 0.00000, -45.06000);
	CreateObject(8406, -2599.27905, 686.97528, 33.46810,   0.00000, 0.00000, -90.00000);
	CreateObject(9931, -2566.70508, 512.03558, 30.14760,   0.00000, 0.00000, 90.00000);
	CreateObject(19550, -2550.43628, 499.29391, 13.44740,   0.00000, 0.00000, 0.00000);
	CreateObject(982, -2536.70288, 540.48590, 14.13290,   0.00000, 0.00000, 0.00000);
	CreateObject(984, -2555.24414, 553.26642, 14.08380,   0.00000, 0.00000, 90.00000);
	CreateObject(984, -2543.08716, 553.27716, 14.08380,   0.00000, 0.00000, 90.00000);
	CreateObject(984, -2578.10400, 553.26642, 14.08380,   0.00000, 0.00000, 90.00000);
	CreateObject(984, -2590.26392, 553.26642, 14.08380,   0.00000, 0.00000, 90.00000);
	CreateObject(982, -2596.65479, 540.47412, 14.13290,   0.00000, 0.00000, 0.00000);
	CreateObject(982, -2595.62036, 15.82390, 14.13290,   0.00000, 0.00000, 0.00000);
	CreateObject(982, -2596.65479, 514.85413, 14.13290,   0.00000, 0.00000, 0.00000);
	CreateObject(982, -2596.65479, 491.15411, 14.13290,   0.00000, 0.00000, 0.00000);
	CreateObject(983, -2553.52246, 478.98221, 14.14380,   0.00000, 0.00000, -78.58002);
	CreateObject(982, -2583.85254, 478.35620, 14.13290,   0.00000, 0.00000, -90.00000);
	CreateObject(982, -2569.49243, 478.35620, 14.13290,   0.00000, 0.00000, -90.00000);
	CreateObject(983, -2552.02075, 479.29999, 14.14380,   0.00000, 0.00000, -78.58000);
	CreateObject(983, -2546.21973, 481.73120, 14.14380,   0.00000, 0.00000, -55.83998);
	CreateObject(983, -2545.20605, 482.43250, 14.14380,   0.00000, 0.00000, -55.84000);
	CreateObject(983, -2540.76831, 486.87854, 14.14380,   0.00000, 0.00000, -34.09998);
	CreateObject(983, -2540.06177, 487.92319, 14.14380,   0.00000, 0.00000, -34.09998);
	CreateObject(983, -2537.63452, 493.69385, 14.14380,   0.00000, 0.00000, -11.59998);
	CreateObject(983, -2537.31787, 495.25467, 14.14380,   0.00000, 0.00000, -11.59998);
	CreateObject(982, -2536.70288, 514.86591, 14.13290,   0.00000, 0.00000, 0.00000);
	CreateObject(983, -2536.69556, 501.58670, 14.14380,   0.00000, 0.00000, 0.00000);//SFMD_IGLESIA
	CreateObject(969, -1571.68140, 665.89929, 6.17960,   0.00000, 0.00000, -90.00000);//SFPD
	CreateObject(19447, -1571.81030, 652.39563, 7.61320,   0.00000, 0.00000, 0.00000);
	CreateObject(7657, -1631.71655, 688.07013, 7.90100,   0.00000, 0.00000, 0.00000);
	CreateObject(1652, -1628.76172, 688.08331, 10.31500,   0.00000, 0.00000, 0.00000);
	CreateObject(2008, -1615.71106, 680.21002, 6.18540,   0.00000, 0.00000, -180.00000);
	CreateObject(2356, -1616.51196, 681.07813, 6.18560,   0.00000, 0.00000, -180.00000);
	CreateObject(2606, -1613.85583, 681.06140, 8.54588,   0.00000, 0.00000, -87.54000);
	CreateObject(2612, -1615.92847, 687.86517, 7.93040,   0.00000, 0.00000, 0.00000);
	CreateObject(18646, -1623.08569, 687.91083, 11.20760,   90.00000, 0.00000, 0.00000);
	CreateObject(2066, -1618.04675, 687.44232, 6.18380,   0.00000, 0.00000, -2.21998);
	CreateObject(11730, -1614.03162, 685.21228, 6.18414,   0.00000, 0.00000, -87.18001);
	CreateObject(18636, -1613.73999, 686.21161, 7.99270,   0.00000, 90.00000, -180.00000);
	CreateObject(18637, -1614.03870, 687.83942, 6.66730,   78.42000, 0.00000, -45.00000);
	CreateObject(19969, -1594.57690, 723.41510, 8.98840,   0.00000, 0.00000, -90.00000);
	CreateObject(968, -1701.48547, 687.60449, 24.67640,   0.00000, 0.00000, -90.00000);
	CreateObject(19868, -1701.62634, 692.24231, 23.87270,   0.00000, 0.00000, 90.00000);
	CreateObject(19868, -1701.62634, 697.50232, 23.87270,   0.00000, 0.00000, 90.00000);
	CreateObject(19868, -1701.62634, 702.76233, 23.87270,   0.00000, 0.00000, 90.00000);
	CreateObject(19868, -1701.62634, 708.02228, 23.87270,   0.00000, 0.00000, 90.00000);
	CreateObject(19868, -1701.62634, 713.28229, 23.87270,   0.00000, 0.00000, 90.00000);
	CreateObject(19868, -1701.62634, 716.14227, 23.87270,   0.00000, 0.00000, 90.00000);
	CreateObject(19868, -1698.99487, 718.73468, 23.87270,   0.00000, 0.00000, 0.00000);
	CreateObject(19868, -1697.57495, 718.73468, 23.87270,   0.00000, 0.00000, 0.00000);
	CreateObject(982, -1682.13586, 718.73700, 24.56750,   0.00000, 0.00000, 90.00000);
	CreateObject(982, -1656.52185, 718.73877, 24.56750,   0.00000, 0.00000, 90.00000);//SFPD
	CreateObject(7520, -2901.87622, 430.31241, 4.22770,   0.00000, 0.00000, 180.00000);//Taller SF
	CreateObject(3624, -2982.89648, 471.09171, 8.53860,   0.00000, 0.00000, -180.00000);
	CreateObject(11392, -2982.95239, 469.56619, 3.90940,   0.00000, 0.00000, -24.42000);
	CreateObject(10282, -2991.29541, 471.51489, 4.92660,   0.00000, 0.00000, 90.00000);
	CreateObject(11401, -2992.49829, 462.87399, 7.65890,   0.00000, 0.00000, 90.00000);
	CreateObject(1984, -2972.07007, 462.43744, 3.90670,   0.00000, 0.00000, 90.00000);
	CreateObject(2583, -2973.55054, 459.14011, 5.53570,   0.00000, 0.00000, -180.00000);
	CreateObject(2700, -2978.39063, 459.14520, 7.38661,   0.00000, 0.00000, 90.00000);
	CreateObject(1073, -2996.53394, 468.72089, 7.72140,   0.00000, 0.00000, 0.00000);
	CreateObject(14826, -2973.92041, 479.32224, 4.63160,   0.00000, 0.00000, -180.00000);
	CreateObject(1139, -2988.90308, 483.09955, 6.99100,   0.00000, 0.00000, -180.00000);
	CreateObject(1096, -2996.51929, 473.40649, 7.76120,   0.00000, 0.00000, 0.00000);
	CreateObject(1080, -2996.56201, 471.00391, 8.16190,   0.00000, 0.00000, 0.00000);
	CreateObject(1650, -2969.70410, 459.31250, 5.42950,   0.00000, 0.00000, -145.20003);
	CreateObject(2690, -2970.30591, 459.30225, 5.47845,   0.00000, 0.00000, -148.19998);
	CreateObject(2165, -2978.88086, 480.02490, 3.87740,   0.00000, 0.00000, -180.00000);
	CreateObject(2161, -2979.15967, 482.98441, 5.10380,   0.00000, 0.00000, 0.00000);
	CreateObject(1671, -2979.46411, 480.96066, 4.34844,   0.00000, 0.00000, 0.00000);
	CreateObject(1721, -2979.23242, 478.61581, 3.89600,   0.00000, 0.00000, 0.00000);
	CreateObject(1146, -2989.15454, 483.13440, 6.07290,   0.00000, 0.00000, 180.00000);
	CreateObject(1147, -2985.24414, 483.07950, 7.02070,   0.00000, 0.00000, 180.00000);
	CreateObject(1138, -2985.80078, 483.10959, 6.28310,   0.00000, 0.00000, 180.00000);
	CreateObject(981, -2947.57715, 485.98535, 3.88446,   0.00000, 0.00000, 0.00000);
	CreateObject(16360, -2869.74561, 505.38287, 4.00813,   0.00000, 0.00000, 0.00000);
	CreateObject(7391, -2854.62671, 507.06738, 8.76140,   0.00000, 0.00000, -39.47999);
	CreateObject(16362, -2903.47998, 503.10861, 6.99890,   0.00000, 0.00000, 90.00000);
	CreateObject(1676, -2885.44043, 503.15790, 5.61360,   0.00000, 0.00000, 90.00000);
	CreateObject(1676, -2891.46045, 503.15790, 5.61360,   0.00000, 0.00000, 90.00000);
	CreateObject(1676, -2897.44019, 503.15790, 5.61360,   0.00000, 0.00000, 90.00000);
	CreateObject(1676, -2909.44019, 503.15790, 5.61360,   0.00000, 0.00000, 90.00000);
	CreateObject(1676, -2903.44019, 503.15790, 5.61360,   0.00000, 0.00000, 90.00000);
	CreateObject(1676, -2915.44019, 503.15790, 5.61360,   0.00000, 0.00000, 90.00000);
	CreateObject(1676, -2921.44019, 503.15790, 5.61360,   0.00000, 0.00000, 90.00000);
	CreateObject(3096, -2968.97144, 471.10770, 11.31438,   0.00000, 0.00000, -90.00000);
	CreateObject(10281, -2995.89673, 471.15131, 11.46070,   0.00000, -15.00000, 90.00000);//Taller SF
	CreateObject(1344, 870.47070, -1364.18445, 13.35540,   0.00000, 0.00000, 179.15990);//Callejon Market
	CreateObject(1362, 868.09540, -1357.18286, 13.24222,   0.00000, 0.00000, 0.00000);
	CreateObject(4730, 858.41028, -1356.30054, 20.06916,   0.00000, 0.00000, -187.43980);
	CreateObject(1728, 868.18622, -1353.41040, 12.58880,   0.00000, 0.00000, 90.12000);
	CreateObject(1711, 870.92432, -1349.74976, 12.68680,   0.00000, 0.00000, -21.72000);
	CreateObject(19878, 867.84735, -1344.81860, 12.96570,   0.00000, 127.00000, 98.00000);
	CreateObject(1433, 870.62512, -1352.36572, 12.91197,   0.00000, 0.00000, 0.00000);
	CreateObject(1411, 877.12604, -1343.70032, 14.08590,   356.85840, 0.00000, -1.35840);
	CreateObject(1438, 868.93134, -1345.08606, 12.56420,   0.00000, 0.00000, 0.00000);
	CreateObject(1349, 879.36023, -1363.74377, 13.17920,   0.00000, 0.00000, -164.16000);
	CreateObject(1369, 871.61066, -1354.22742, 13.33026,   0.00000, 0.00000, -134.15999);
	CreateObject(1338, 848.62817, -1361.76782, 13.62075,   0.00000, 30.00000, -143.03990);
	CreateObject(1414, 870.30255, -1343.96484, 13.85915,   0.00000, 0.00000, 0.00000);
	CreateObject(1458, 849.94867, -1360.73682, 12.88532,   0.00000, 0.00000, -228.05992);
	CreateObject(1503, 876.15070, -1346.17468, 12.98085,   0.00000, 0.00000, -1.38002);
	CreateObject(926, 849.25366, -1360.73486, 13.77554,   0.00000, -20.00000, -287.00000);
	CreateObject(2676, 865.36102, -1371.31580, 12.66500,   0.00000, 0.00000, 115.68000);
	CreateObject(2673, 870.53851, -1352.22620, 12.71590,   0.00000, 0.00000, -13.38000);
	CreateObject(1439, 867.07031, -1370.14587, 12.67320,   0.00000, 0.00000, -89.22000);//Callejon Market
	CreateObject(3092, 2419.33203, -1660.13354, 20.30020,   0.00000, 0.00000, 87.42000);//Groove
	CreateObject(19087, 2419.38599, -1660.06116, 23.46920,   0.00000, 0.00000, 0.00000);
	CreateObject(14467, 2487.57837, -1668.85913, 15.12260,   0.00000, 0.00000, -92.76000);
	CreateObject(1362, 2423.85229, -1677.85229, 13.38230,   0.00000, 0.00000, 0.00000);
	CreateObject(1344, 2440.98535, -1692.55103, 13.60450,   0.00000, 0.00000, 148.55989);
	CreateObject(1327, 2431.87646, -1679.52795, 13.34390,   0.00000, -90.00000, 0.00000);
	CreateObject(3594, 2429.83984, -1679.41321, 13.92110,   0.00000, 0.00000, -90.00000);
	CreateObject(17969, 2436.19751, -1680.93396, 13.95310,   0.00000, 0.00000, -90.24000);
	CreateObject(18660, 2424.68213, -1680.94434, 16.04660,   0.00000, 0.00000, -90.00000);
	CreateObject(1327, 2427.80029, -1679.38196, 13.34390,   0.00000, -90.00000, 0.00000);
	CreateObject(2056, 2434.24780, -1680.94067, 14.35272,   0.00000, 0.00000, -181.62010);
	CreateObject(2051, 2429.95239, -1680.90942, 15.84990,   0.00000, 0.00000, -181.80000);
	CreateObject(1520, 2432.39063, -1679.08752, 14.19060,   0.00000, 0.00000, -42.00005);
	CreateObject(1484, 2431.55884, -1678.96375, 14.42443,   4.02000, 30.30000, 3.54000);
	CreateObject(2049, 2426.73877, -1680.91016, 14.96350,   0.00000, 13.00000, -181.73990);
	CreateObject(1487, 2429.60571, -1678.77722, 14.70410,   0.00000, 0.00000, -123.47993);
	CreateObject(1669, 2426.98975, -1678.86597, 14.37690,   0.00000, 0.00000, 31.68000);
	CreateObject(1551, 2427.89453, -1678.55774, 14.45210,   0.00000, 0.00000, -115.07999);
	CreateObject(18688, 2423.83887, -1677.84375, 12.50730,   0.00000, 0.00000, 0.00000);
	CreateObject(18659, 2419.33252, -1659.71240, 24.31130,   0.00000, 0.00000, 0.00000);
	CreateObject(1728, 2428.58667, -1633.56396, 12.41380,   0.00000, 0.00000, 0.00000);
	CreateObject(1711, 2427.06543, -1634.43213, 12.42090,   0.00000, 0.00000, 45.00000);
	CreateObject(3171, 2435.60498, -1632.59949, 12.37890,   0.00000, 0.00000, 45.00000);
	CreateObject(19997, 2429.63330, -1636.11621, 12.15842,   0.00000, 0.00000, -89.16000);
	CreateObject(1711, 2431.86768, -1634.23328, 12.42090,   0.00000, 0.00000, -53.87999);
	CreateObject(1410, 2429.32959, -1629.31726, 13.13630,   3.13670, 0.02600, 0.00000);
	CreateObject(1410, 2433.98950, -1629.31726, 13.13630,   3.13670, 0.02600, 0.00000);
	CreateObject(19823, 2429.90918, -1636.02405, 13.00180,   0.00000, 0.00000, -33.30000);
	CreateObject(3027, 2429.76636, -1635.66113, 13.00000,   90.00000, 0.00000, -77.40000);
	CreateObject(1665, 2429.30762, -1635.74634, 13.01310,   0.00000, 0.00000, 85.20002);
	CreateObject(1486, 2429.54932, -1636.14160, 13.15300,   0.00000, 0.00000, 335.04001);
	CreateObject(19831, 2422.58765, -1638.33154, 12.48460,   0.00000, 0.00000, 90.00000);
	CreateObject(19812, 2438.56104, -1636.82507, 12.93640,   0.00000, 0.00000, -74.46000);//Groove
	return 1;
}
public PayDay(playerid)
{
    for (new i; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i) && Logueado[i])
        {
            new msg[100], exp, lvl, expr, string[200], p, d;
            expr= (PlayersData[i][ExperienciaRe]);
            exp= (PlayersData[i][Experiencia]);
            lvl= (PlayersData[i][Nivel]);
            p=250;
            d=PlayersData[i][Dinero]-10;
            GivePlayerMoney(i, p-10);
            SendClientMessage(i, -1, "{FBDA8E}|___________________ {008000}Banco{FBDA8E} ___________________|\n");
            format(string, sizeof(string), "{BDF766}Banco: Nuevo Balance: $%d", d);
            SendClientMessage(i, -1, string);
            format(string, sizeof(string), "{BDF766}Banco: Paga: $%d", p);
            SendClientMessage(i, -1, string);
            format(string, sizeof(string), "{BDF766}Banco: Intereses: $10");
            SendClientMessage(i, -1, string);
            SendClientMessage(i, -1, "{FBDA8E}|_____________________ {008000}Fin{FBDA8E} ____________________|");
    		format(msg, sizeof(msg), "~B~Hora de la Paga!");
			GameTextForPlayer(i, msg, 1000, 1);
            PlayersData[i][Experiencia]++;
            PlayerPlaySound(i, 1133, 0, 0, 10.0);
            YSI_Save_Account(i);
            if (exp == expr)
            {
				PlayersData[i][Nivel]++;
				SetPlayerScore(i, GetPlayerScore(playerid)+1);
				PlayersData[i][ExperienciaRe]= PlayersData[i][ExperienciaRe]+4;
				PlayersData[i][Experiencia]=0;
			}
			if ( lvl > 1 )
			{
				expr= expr+4;
			}
        }
    }
    return 1;
}
public SetPlayerHealthEx(playerid, Float:vida)
{
    PlayersData[playerid][Vida] = vida;
	SetPlayerHealth(playerid, vida);
	return 1;
}
public SetPlayerPosEx(playerid, Float: Pos_X, Float: Pos_Y, Float: Pos_Z)
{
	SetPlayerPos(playerid, Pos_X, Pos_Y, Pos_Z);
	PlayersData[playerid][Pos][0] = Pos_X; PlayersData[playerid][Pos][1] = Pos_Y; PlayersData[playerid][Pos][2] = Pos_Z;
	return 1;
}

public SetPlayerArmourEx(playerid, Float: chaleco)
{
	SetPlayerArmour(playerid, chaleco);
	PlayersData[playerid][Chaleco] = chaleco;
	return 1;
}


public YSI_Load_Account(playerid, name[], value[])
{

	INI_Int("Admin",			PlayersData[playerid][Admin]);
	INI_Int("Vip",              PlayersData[playerid][Vip]);
    INI_String("Password",      PlayersData[playerid][Password], MAX_TEXTOS_CORTOS);
	INI_Float("Pos_X",			PlayersData[playerid][Pos][0]);
	INI_Float("Pos_Y",			PlayersData[playerid][Pos][1]);
	INI_Float("Pos_Z",			PlayersData[playerid][Pos][2]);
	INI_Float("Vida",	    	PlayersData[playerid][Vida]);
	INI_Float("Chaleco",		PlayersData[playerid][Chaleco]);
	INI_Int("Nivel",			PlayersData[playerid][Nivel]);
	INI_Int("Experiencia",		PlayersData[playerid][Experiencia]);
	INI_Int("ExperienciaRe",    PlayersData[playerid][ExperienciaRe]);
	INI_Int("Faccion",			PlayersData[playerid][Faccion]);
	INI_Int("Rango",			PlayersData[playerid][Rango]);
	INI_Int("Interior",			PlayersData[playerid][Interior]);
	INI_Int("Skin",	        	PlayersData[playerid][Skin]);
	INI_Int("Acento",           PlayersData[playerid][Acento]);
	INI_Int("Dinero",			PlayersData[playerid][Dinero]);
	INI_Int("World",			PlayersData[playerid][World]);
    INI_Int("AdminOn",			PlayersData[playerid][AdminOn]);
    INI_Int("Ciudad",			PlayersData[playerid][Ciudad]);
    INI_Int("Sexo",			    PlayersData[playerid][Sexo]);
    INI_String("Relacion",      PlayersData[playerid][Relacion], MAX_TEXTOS_LARGOS);
    INI_Int("Estado",           PlayersData[playerid][Estado]);
    INI_Int("Edad",		    	PlayersData[playerid][Edad]);
    INI_Int("Baneado",			PlayersData[playerid][Baneado]);
    INI_Int("Warn",             PlayersData[playerid][Warn]);
	return 1;
}


public YSI_Save_Account(playerid)
{
	static
        LoopArmas[2][13];
	if(Logueado[playerid] == true)
	{
        GetPlayerHealth(playerid, PlayersData[playerid][Vida]);
        GetPlayerArmour(playerid, PlayersData[playerid][Chaleco]);
        PlayersData[playerid][Dinero] = GetPlayerMoney(playerid);
        GetPlayerPos(playerid, PlayersData[playerid][Pos][0], PlayersData[playerid][Pos][1], PlayersData[playerid][Pos][2]);
        PlayersData[playerid][Interior] = GetPlayerInterior(playerid);
        PlayersData[playerid][World] = GetPlayerVirtualWorld(playerid);
        PlayersData[playerid][Skin] = GetPlayerSkin(playerid);

 		new PlayerAccountData[MAX_PLAYER_ACCOUNT_DATA];
		format(PlayerAccountData, sizeof(PlayerAccountData), "%s%s.ini", DIR_CUENTAS, PlayerName(playerid));
		new INI:PlayerStatsData = INI_Open(PlayerAccountData);
		INI_WriteInt(PlayerStatsData, 		"Admin",       		PlayersData[playerid][Admin]);
		INI_WriteInt(PlayerStatsData,       "Vip",              PlayersData[playerid][Vip]);
		INI_WriteString(PlayerStatsData, 	"Password", 		PlayersData[playerid][Password]);
		INI_WriteFloat(PlayerStatsData, 	"Pos_X",			PlayersData[playerid][Pos][0]);
		INI_WriteFloat(PlayerStatsData, 	"Pos_Y",			PlayersData[playerid][Pos][1]);
		INI_WriteFloat(PlayerStatsData, 	"Pos_Z",			PlayersData[playerid][Pos][2]);
		INI_WriteFloat(PlayerStatsData, 	"Vida",			    PlayersData[playerid][Vida]);
		INI_WriteFloat(PlayerStatsData, 	"Chaleco",  	    PlayersData[playerid][Chaleco]);
		INI_WriteInt(PlayerStatsData, 		"Nivel", 			PlayersData[playerid][Nivel]);
        INI_WriteInt(PlayerStatsData, 		"Experiencia", 		PlayersData[playerid][Experiencia]);
        INI_WriteInt(PlayerStatsData,       "ExperienciaRe",    PlayersData[playerid][ExperienciaRe]);
        INI_WriteInt(PlayerStatsData, 		"Faccion", 			PlayersData[playerid][Faccion]);
        INI_WriteInt(PlayerStatsData, 		"Rango", 			PlayersData[playerid][Rango]);
        INI_WriteInt(PlayerStatsData, 		"Interior", 		PlayersData[playerid][Interior]);
		INI_WriteInt(PlayerStatsData,		"Skin",	        	PlayersData[playerid][Skin]);
		INI_WriteInt(PlayerStatsData,       "Acento",           PlayersData[playerid][Acento]);
        INI_WriteInt(PlayerStatsData, 		"Dinero", 			PlayersData[playerid][Dinero]);
        INI_WriteInt(PlayerStatsData, 		"World", 			PlayersData[playerid][World]);
        INI_WriteInt(PlayerStatsData, 		"AdminOn", 			PlayersData[playerid][AdminOn]);
        INI_WriteInt(PlayerStatsData, 		"Ciudad", 			PlayersData[playerid][Ciudad]);
        INI_WriteInt(PlayerStatsData, 		"Sexo", 			PlayersData[playerid][Sexo]);
        INI_WriteString(PlayerStatsData,    "Relacion",         PlayersData[playerid][Relacion]);
        INI_WriteInt(PlayerStatsData,       "Estado",           PlayersData[playerid][Estado]);
        INI_WriteInt(PlayerStatsData, 		"Edad", 			PlayersData[playerid][Edad]);
        INI_WriteInt(PlayerStatsData, 		"Baneado", 			PlayersData[playerid][Baneado]);
        INI_WriteInt(PlayerStatsData,       "Warn",             PlayersData[playerid][Warn]);
		for( new i; i < 13; i++ )
		{
            GetPlayerWeaponData(playerid, i, PlayersData[playerid][Armas][i], PlayersData[playerid][Municiones][i]);
            format( LoopArmas[ 0 ], 13, "Armas[%i]", i)        , INI_WriteInt(PlayerStatsData , LoopArmas[0], PlayersData[playerid][Armas][i]);
            format( LoopArmas[ 1 ], 13, "Municiones[%i]", i )	, INI_WriteInt(PlayerStatsData , LoopArmas[1], PlayersData[playerid][Municiones][i]);
 	    }
		INI_Close(PlayerStatsData);
	}
	return 1;
}
public SendInfoMessage(playerid, type, optional[], message[])
{
	new MsgInfo[MAX_TEXT_CHAT];
	switch ( type )
	{
	    // Error
	    case 0:
	    {
	        format(MsgInfo, sizeof(MsgInfo), ">>{FFFFFF} %s", message);
		}
		// Ayuda
	    case 1:
	    {
	        format(MsgInfo, sizeof(MsgInfo), "{00C0F6}%s{FFFFFF} %s", message, optional);
		}
		// Información
	    case 2:
	    {
	        format(MsgInfo, sizeof(MsgInfo), "Info:{FFFFFF} %s", message);
		}
		// Afirmativo
	    case 3:
	    {
	        format(MsgInfo, sizeof(MsgInfo), "Importante:{FFFFFF} %s", message);
		}
		// Entorno
 	    case 4:
	    {
	        format(MsgInfo, sizeof(MsgInfo), "[- {8480D1}Entorno{FFFFFF} -] %s", message);
		}
	}
	SendClientMessage(playerid, COLOR_MESSAGES[type], MsgInfo);
}
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	if(PlayersData[playerid][Admin] >= 3)
    {
	    SetPlayerPos(playerid, fX, fY, fZ);
		SendClientMessageEx(playerid, -1, "%sSe te ha transportado hasta el punto en el mapa.", AdminMsg);
    }
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	if( PlayersData[playerid][Admin] >= 3)
	{
    	new Float:pX, Float:pY, Float:pZ, Mensaje[120];
    	GetPlayerPos(clickedplayerid, pX, pY, pZ);
    	SetPlayerPos(playerid, pX, pY, pZ);
    	format(Mensaje, sizeof(Mensaje), "%sHas ido a la posición de %s", AdminMsg, RemoveUnderScore(clickedplayerid));
    	SendClientMessage(playerid, -1, Mensaje);
	}
	return 1;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////-----------===============================[ - Comandos - ]===============================-----------//////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CMD:ayuda(playerid, params[]) //COMANDO /Ayuda
{
    ShowPlayerDialog(playerid, DIALOG_AYUDA, DIALOG_STYLE_LIST, "Ayuda - {484EFA}American{FFFFFF} Role{FFFF00}Play","{005EF6}» {FFFFFF}General (Comandos Generales)\n{005EF6}» {FFFFFF}Chat (Comandos del Chat)\n{005EF6}» {FFFFFF}Vivienda (Comandos de las viviendas)\n{005EF6}» {FFFFFF}Créditos (Créditos Oficiales del servidor)", "Seleccionar", "Cancelar");
    return 1;
}
CMD:entorno(playerid, params[])
{
	new edad, entorno[250];
	edad= PlayersData[playerid][Edad];
	format(entorno, sizeof(entorno), "{82FF82}[Entorno]:{FFFF95} Recién llegas al Estado de San Andreas, con %d años de edad, para sobrevivir, debes buscar un empleo...", edad);
	SendClientMessage(playerid, -1, entorno);
	format(entorno, sizeof(entorno), "{82FF82}[Entorno]:{FFFF95} El banco te ha ofrecido un cheque por {008040}$1,200 {FFFF95}dólares los cuales deberás usar para sobrevivir...", edad);
	SendClientMessage(playerid, -1, entorno);
	format(entorno, sizeof(entorno), "{82FF82}[Entorno]:{FFFF95} Deberías ir a una tienda de /AutoServicio para comprar un móvil y buscar un empleo, suerte!", edad);
	SendClientMessage(playerid, -1, entorno);
	return 1;
}
CMD:me(playerid, params[])//COMANDO /Me
{
    if(isnull(params)) return SendClientMessageEx(playerid, -1, "%sUtiliza /me <acción>", InfMsg);
    new string[128 + MAX_PLAYER_NAME];
    format(string, sizeof(string), "*%s %s", RemoveUnderScore(playerid), params);
    DetectorCercania(15.0, playerid, string, 0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA);
    return 1;
}
CMD:susurrar(playerid, params[])//COMANDO /Susurrar
{
    if(isnull(params)) return SendClientMessageEx(playerid, -1, "%sUtiliza /Susurrar <texto>", InfMsg);
    new string[128 + MAX_PLAYER_NAME];
    format(string, sizeof(string), "%s susurra: %s", RemoveUnderScore(playerid), params);
    DetectorCercania(3.0, playerid, string, 0xBB00BBFF,0xBB00BBFF,0xBB00BBFF,0xBB00BBFF,0xBB00BBFF);
    return 1;
}
CMD:do(playerid, params[])//COMANDO /Ame
{
    if(isnull(params)) return SendClientMessageEx(playerid, -1, "%sUtiliza /ame <entorno>", InfMsg);
    new string[128 + MAX_PLAYER_NAME];
    format(string, sizeof(string), "**%s [ID:%d]", params, playerid);
    DetectorCercania(15.0, playerid, string, 0x55FF80FF,0x84FFA3FF,0x84FFA3FF,0x84FFA3FF,0x84FFA3FF);
    return 1;
}
CMD:intentar(playerid, params[])//COMANDO /Intentar
{
    if(Intentar[playerid] == false) return SendClientMessage(playerid, -1, "{A7A7A7}** Debes esperar 10 segundos para volver a utilizar el comando.");
    if(isnull(params)) return SendClientMessageEx(playerid, 1, "%sUtiliza /intentar <texto>", InfMsg);
    new string[128 + MAX_PLAYER_NAME];
    new rand = random(100);
    if(rand < 50)
    {
        format(string, sizeof(string), "* %s intentó %s y lo consiguió!", RemoveUnderScore(playerid), params);
        DetectorCercania(15.0, playerid, string, 0x008000FF,0x008000FF,0x008000FF,0x008000FF,0x008000FF);
    }
    else
    {
        format(string, sizeof(string), "* %s intentó %s pero no lo logro.", RemoveUnderScore(playerid), params);
        DetectorCercania(15.0, playerid, string, 0xFF0000FF,0xFF0000FF,0xFF0000FF,0xFF0000FF,0xFF0000FF);
    }
    Intentar[playerid] = false;
    SetTimerEx("IntentarTimer", 10000, false, "i", playerid);
    return 1;
}
CMD:g(playerid, params[])//COMANDO /Gritar
{
    if(isnull(params)) return SendClientMessageEx(playerid, -1, "%sUtiliza /Gritar <Grito>", InfMsg);
    new string[128 + MAX_PLAYER_NAME];
    format(string, sizeof(string), "%s grita: %s!!!", RemoveUnderScore(playerid), params);
    DetectorCercania(20.0, playerid, string, 0xE6E6E6E6,0xC8C8C8C8,0xAAAAAAAA,0x8C8C8C8C,0x6E6E6E6E);
    return 1;
}
CMD:b(playerid, params[])//COMANDO /B
{
    if(isnull(params)) return SendClientMessageEx(playerid, -1, "%sUtiliza /B <texto>", InfMsg);
    new string[128 + MAX_PLAYER_NAME];
    format(string, sizeof(string), "[OOC]%s: (( %s ))", RemoveUnderScore(playerid), params);
    DetectorCercania(10.0, playerid, string, 0xE6E6E6E6,0xC8C8C8C8,0xAAAAAAAA,0x8C8C8C8C,0x6E6E6E6E);
    return 1;
}
CMD:pasaporte(playerid, params[])//COMANDO /Pasaporte
{
	if (isnull(params))
 	{
  		SendClientMessageEx(playerid, 0, "0", "%sUtiliza /Pasaporte [ID]", InfMsg);
    	return 1;
	}
	new pID, string[300], ciudad[15], sexo[10], edad, trabajo[50], cargo[25], relacion[30];
	pID=strval(params);
	if(!IsPlayerConnected(pID)) return SendClientMessageEx(playerid, -1, "%sJugador no conectado.", InfMsg);
    if(ProxDetectorS(5.0, playerid, pID) || playerid == pID)
    {
	if(PlayersData[playerid][Ciudad] == 1) { ciudad="Los Santos";}
	if(PlayersData[playerid][Ciudad] == 2) { ciudad="San Fierro";}
	if(PlayersData[playerid][Ciudad] == 3) { ciudad="Las Venturas";}
	if(PlayersData[playerid][Sexo] == 1)	{   sexo="Femenino";}
	if(PlayersData[playerid][Sexo] == 2) {   sexo="Masculino";}
	edad = PlayersData[playerid][Edad];
	trabajo= "Ninguno";
	cargo= "Ninguno";
	relacion= "Soltero";
    if (playerid == pID)
    {
		format(string, sizeof(string), "{FF8040}Nombre: {FFFFFF}%s\n{FF8040}Sexo: {FFFFFF}%s\n{FF8040}Edad: {FFFFFF}%d\n{FF8040}Residencia: {FFFFFF}%s\n{FF8040}Trabajo: {FFFFFF}%s\n{FF8040}Cargo: {FFFFFF}%s\n{FF8040}Relación: {FFFFFF}%s", RemoveUnderScore(playerid), sexo, edad, ciudad, trabajo, cargo, relacion);
		ShowPlayerDialog(pID, DIALOG_PASAPORTE, DIALOG_STYLE_MSGBOX, "\t{C0C0C0}....::{0080FF}San {FF0000}Andreas {FF8000}Passport{C0C0C0}::....", string, "Aceptar","");
		SendClientMessageEx(playerid, -1, "%sHaz revisado tu pasaporte", InfoMsg);
	}
	else
	{
	format(string, sizeof(string), "{FF8040}Nombre: {FFFFFF}%s\n{FF8040}Sexo: {FFFFFF}%s\n{FF8040}Edad: {FFFFFF}%d\n{FF8040}Residencia: {FFFFFF}%s\n{FF8040}Trabajo: {FFFFFF}%s\n{FF8040}Cargo: {FFFFFF}%s\n{FF8040}Relación: {FFFFFF}%s", RemoveUnderScore(playerid), sexo, edad, ciudad, trabajo, cargo, relacion);
	ShowPlayerDialog(pID, DIALOG_PASAPORTE, DIALOG_STYLE_MSGBOX, "\t{C0C0C0}....::{0080FF}San {FF0000}Andreas {FF8000}Passport{C0C0C0}::....", string, "Aceptar","");
	SendClientMessageEx(pID, -1, "%s%s te ha enseñado su pasaporte", InfoMsg, RemoveUnderScore(playerid));
	SendClientMessageEx(playerid, -1, "%sLe haz enseñado tu pasaporte a %s", InfoMsg, RemoveUnderScore(pID));
	}
	return 1;
    }
	else
	{
	SendClientMessageEx(playerid, -1, "%sEl jugador se encuentra muy lejos.", InfMsg);
	}
	return 1;
}
CMD:vc(playerid, params[])//COMANDO /VC
{
	if( PlayersData[playerid][Vip] >= 1 )
	{
	    if (isnull(params))
        {
            SendClientMessageEx(playerid, -1, "%sUtiliza /vc [Texto]", VIPMsg);
            return 1;
		}
	    new VIPRank[64];
	    if(PlayersData[playerid][Vip] == 1) { VIPRank = "{E6C71A}VIP"; }
		else if(PlayersData[playerid][Vip] == 2) { VIPRank = "{FF8080}Admin{E6C71A}VIP"; }
	    if (strlen(params) > 125)
		{
	        SendClientMessageX(-1, "%s%s  {FFFFFF}%s{FFFF80}: %.64s", VIPMsg, VIPRank, RemoveUnderScore(playerid), params);
	        SendClientMessageX(-1, "...%s", params[64]);
	    }
	    else
		{
	        SendClientMessageX(-1, "%s%s  {FFFFFF}%s{FFFF80}: %s", VIPMsg, VIPRank, RemoveUnderScore(playerid), params);
		}
	}
	else
	{
	    SendClientMessageEx(playerid, -1,"%sDebes ser miembro VIP para disfrutar de estas caracteristicas.", VIPMsg);
	}
	return 1;
}
CMD:stats(playerid, params[])
{
	new string2[400], dinero, sexo[10], skin, Float:chaleco, nAdmin[35], exp, lvl, expr;
	dinero= GetPlayerMoney(playerid);
	if(PlayersData[playerid][Sexo] ==1){    sexo= "Femenino";}
	if(PlayersData[playerid][Sexo] ==2){    sexo= "Masculino";}
	skin= GetPlayerSkin(playerid);
	GetPlayerArmour(playerid, chaleco);
	exp= (PlayersData[playerid][Experiencia]);
	expr= (PlayersData[playerid][ExperienciaRe]);
	lvl= GetPlayerScore(playerid);
 	if(PlayersData[playerid][Admin] == 0) { nAdmin = "{FFFFFF}Ninguno."; }
 	else if(PlayersData[playerid][Admin] == 1) { nAdmin = "{80FFFF}Ayudante"; }
	else if(PlayersData[playerid][Admin] == 2) { nAdmin = "{00FF00}Staff"; }
	else if(PlayersData[playerid][Admin] == 3) { nAdmin = "{0080FF}Moderador"; }
	else if(PlayersData[playerid][Admin] == 4) { nAdmin = "{800040}Coordinador"; }
	else if(PlayersData[playerid][Admin] == 5) { nAdmin = "{FF0000}Co-Admin"; }
	else if(PlayersData[playerid][Admin] == 6) { nAdmin = "{400000}Administrador"; }
	else if(PlayersData[playerid][Admin] == 7) { nAdmin = "{3C3C3C}Scripter"; }
	format(string2,sizeof(string2),"{0080FF}Nombre: {FFFFFF}%s\n{0080FF}Dinero: {008000}${FFFFFF}%d\n{0080FF}Sexo: {FFFFFF}%s\n{0080FF}Skin: {FFFFFF}%d\n{0080FF}Chaleco: {FFFFFF}%d\n{0080FF}Experiencia: {FFFFFF}%d/%d {0080FF}Nivel: {FFFFFF}%d\n{0080FF}Administración: %s",RemoveUnderScore(playerid), dinero, sexo, skin, chaleco, exp, expr, lvl, nAdmin);
	ShowPlayerDialog(playerid,DIALOG_STATS,DIALOG_STYLE_MSGBOX,"{FF3535}Panel{FFFFFF}» {FF8000}Estadisticas",string2,"Cerrar","");
	return 1;
}
CMD:admins(playerid, params[])
{
	new ladm[150], rango[25], estado[25];
	SendClientMessage(playerid, -1, "{9B9B9B}.................................::::{B90000}Admin{008000} Online{9B9B9B}::::.................................");
	for(new i; i < MAX_PLAYERS; i++)
	{
		if (IsPlayerConnected(i) && PlayersData[i][Admin] >= 1)
		{
		if(PlayersData[i][Admin] == 1) { rango = "{80FFFF}Ayudante"; }
		else if(PlayersData[i][Admin] == 2) { rango = "{00FF00}Staff"; }
  		else if(PlayersData[i][Admin] == 3) { rango = "{0080FF}Moderador"; }
  		else if(PlayersData[i][Admin] == 4) { rango = "{800040}Coordinador"; }
		else if(PlayersData[i][Admin] == 5) { rango = "{FF0000}Co-Admin"; }
 		else if(PlayersData[i][Admin] == 6) { rango = "{400000}Administrador"; }
		else if(PlayersData[i][Admin] == 7) { rango = "{3C3C3C}Scripter";}
		if(PlayersData[i][AdminOn] == 0) { estado = "{868686}Off Duty";}
		else if(PlayersData[i][AdminOn] == 1) { estado = "{FF0000}On Duty";}
		format(ladm, sizeof(ladm), "%s:{FFFFBB} %s {A7A7A7}[%s{A7A7A7}]", rango, RemoveUnderScore(i), estado);
		SendClientMessage(playerid, -1, ladm);
		}
		else if(IsPlayerConnected(i) && PlayersData[i][Admin] == 0)
		{
		    SendClientMessage(i, -1, "{B30000}No hay ningún miembro del Staff disponible.");
		}
 }
	return 1;
}
CMD:copyright(playerid, params[])
{
	new MsgDialogCreditos[800];
 	format(MsgDialogCreditos, sizeof(MsgDialogCreditos),
  	"{005EF6}Específicaciones{FFFFFF} >>\n\n{00A5FF}Versión: {F0F0F0}v1.1\n");
  	strcat(MsgDialogCreditos, "{00A5FF}Creadores: {484EFA}American{FFFFFF} Role{FFFF00}Play {FFFFFF}\n\n");
  	strcat(MsgDialogCreditos, "{F5FF00}Programador:{FFFFFF} {368AC9}J{FFFFFF}G{C0C0C0}-{FFBF00}Studio\n");
   	strcat(MsgDialogCreditos, "{F5FF00}WebScripter:{FFFFFF} {368AC9}J{FFFFFF}G{C0C0C0}-{FF8080}Design\n");
 	strcat(MsgDialogCreditos, "{F5FF00}Mappers:{FFFFFF} {368AC9}J{FFFFFF}G{C0C0C0}-{FFBF00}Studio\n");
 	strcat(MsgDialogCreditos, "{F5FF00}Este servidor es propiedad de: {368AC9}J{FFFFFF}G{C0C0C0}-{FFBF00}Studio {F5FF00}07/11/2016\n");
  	strcat(MsgDialogCreditos, "{F5FF00}Agredecimientos:{FFFFFF} Rockstar Games - SA:MP - Incognito - Y_LESS\n");
   	strcat(MsgDialogCreditos, "\n\n{F5FF00}Creditos © 2016 {484EFA}American{FFFFFF} Role{FFFF00}Play. {FFFFFF}Todos los derechos reservados.");
    ShowPlayerDialog(playerid, 999, DIALOG_STYLE_MSGBOX, "{00A5FF}Créditos © {484EFA}American{FFFFFF} Role{FFFF00}Play", MsgDialogCreditos, "Aceptar", "");
	return 1;
}
CMD:duda(playerid, params[])
{
	new msg[300];
	if (isnull(params))
	{
  		SendClientMessageEx(playerid, -1, "%sUtiliza /Duda [Texto]", AdminMsg);
    	return 1;
	}
	for(new i; i < MAX_PLAYERS; i++)
	{
		if (IsPlayerConnected(i) && PlayersData[i][Admin] >= 1)
		{
 			format(msg, sizeof(msg), "{FF8080}[Dudas]: {FF80C0}%s {A7A7A7}[ID: %d]: %s", RemoveUnderScore(playerid), playerid, params);
			if(PlayersData[i][Admin] >=1)
			{
	    		SendClientMessage(i, -1, msg);
			}
		}
	}
	SendClientMessageEx(playerid, -1, "%sHaz enviado una duda a la administración, espera que te respondan.", InfoMsg);
	return 1;
}
CMD:reportar(playerid, params[])
{
    if(sscanf(params, "us[128]", params[0], params[1])) return SendClientMessageEx(playerid, -1, "%sUtiliza /Reportar [ID] [Razón]", AdminMsg);
    new nombre[MAX_PLAYER_NAME], nombre2[MAX_PLAYER_NAME], string[250];
    GetPlayerName(playerid, nombre, sizeof(nombre));
    GetPlayerName(params[0], nombre2, sizeof(nombre2));
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerConnected(i))
        {
            if(PlayersData[i][Admin] > 0)
            {
                format(string, sizeof(string), "{D50000}[Reportes]: %s[ID:%d] ha reportado a %s[ID:%d]. Razón: %s", nombre, playerid, nombre2, params[0], params[1]);
                SendClientMessage(i, -1, string);
            }
        }
    }
    SendClientMessageEx(playerid, -1, "%sTú reporte ha sido enviado, gracias por reportar!", InfoMsg);
    return 1;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////-----------===============================[ - Comandos Administrativos - ]===============================-----------//////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CMD:cmdstaff(playerid, params[])//COMANDO /CmdStaff
{
	if(PlayersData[playerid][Admin] >= 1)
	{
		if(PlayersData[playerid][Admin] >= 1)
		{
	    	SendClientMessage(playerid, -1, "{8E8E8E}.....................................::::{80FFFF}Ayudante{8E8E8E}::::.....................................");
	    	SendClientMessage(playerid, -1, "{8E8E8E}/CmdStaff - /A [Canal Admin] - /O [Canal General] - /AdminDuty - /Spec [ID]");
      		SendClientMessage(playerid, -1, "{9DFFFF}*Puedes Espectear a los usuarios.");
		}
		if(PlayersData[playerid][Admin] >= 2)
		{
		    SendClientMessage(playerid, -1, "{8E8E8E}.....................................::::{00FF00}Staff{8E8E8E}::::.....................................");
		    SendClientMessage(playerid, -1, "{8E8E8E}/Traer [ID] - /Ir [ID] - /Test [ID] - /Congelar [ID] - /Descongelar [ID] - /Stats [ID] - /ID [ID] - /ZStaff");
      		SendClientMessage(playerid, -1, "{9DFFFF}*Puedes cambiar la posición de los Usuarios.");
		}
		if(PlayersData[playerid][Admin] >= 3)
		{
            SendClientMessage(playerid, -1, "{8E8E8E}.....................................::::{0080FF}Moderador{8E8E8E}::::.....................................");
            SendClientMessage(playerid, -1, "{8E8E8E}/Kick [ID] - /Ban [ID] - /Mute [ID] - /Unmute [ID] - /Spawn [ID]");
            SendClientMessage(playerid, -1, "{9DFFFF}**Puedes dar Click en Mapa o en Usuarios para teletransportarse.");
		}
		if(PlayersData[playerid][Admin] >= 4)
		{
            SendClientMessage(playerid, -1, "{8E8E8E}.....................................::::{800040}Coordinador{8E8E8E}::::.....................................");
            SendClientMessage(playerid, -1, "{8E8E8E}/Vida [ID] - /Matar [ID] - /IrCoord [X] [Y] [Z] - /ClearChat - /Spamear [Texto]");
            SendClientMessage(playerid, -1, "{9DFFFF}**Puedes crear Anuncios Publicitarios al instante. {FF0000}(NO ABUSAR)");
		}
		if(PlayersData[playerid][Admin] >= 5)
		{
		    SendClientMessage(playerid, -1, "{8E8E8E}.....................................::::{FF0000}Co-Admin{8E8E8E}::::.....................................");
		    SendClientMessage(playerid, -1, "{8E8E8E}/DarDinero [ID] [Monto] - /Clima [ID_Clima] - /SetSkin [ID_Skin] - /Weapon [ID_Weapon]");
            SendClientMessage(playerid, -1, "{9DFFFF}*Puedes cambiar el Clima. **Puedes Cambiar el Skin. ***Puedes Dar Armas.{FF0000}(NO ABUSAR)");
		}
		if(PlayersData[playerid][Admin] >= 6)
		{
		    SendClientMessage(playerid, -1, "{8E8E8E}.....................................::::{400000}Administrador{8E8E8E}::::.....................................");
		    SendClientMessage(playerid, -1, "{8E8E8E}/ReiniciarServidor - /ForzarReinicio - /Staff [ID] [Rango] - /DoVip [ID] - /RemoveVip [ID] - /Mohamed [ID]");
 		    SendClientMessage(playerid, -1, "{8E8E8E}/Servidor [Texto] - /MsgEx [Texto]");
            SendClientMessage(playerid, -1, "{9DFFFF}*Puedes dar Rango Administrativo. **Puedes dar Membresías VIP ***Puedes reiniciar el Servidor.{FF0000}(NO ABUSAR)");
  		}
		if(PlayersData[playerid][Admin] >= 7)
		{
		    SendClientMessage(playerid, -1, "{8E8E8E}.....................................::::{3C3C3C}Scripter{8E8E8E}::::.....................................");
		    SendClientMessage(playerid, -1, "{8E8E8E}/Shutdown - /TestPing");
		}
	}
	else
	{
	    SendClientMessageEx(playerid, -1, "%sNo autorizado.", AdminMsg);
	}
	return 1;
}
CMD:a(playerid, params[])
{
	if( PlayersData[playerid][Admin] >= 1 )
	{
	    if (isnull(params))
        {
            SendClientMessageEx(playerid, -1, "%sUtiliza /A [Texto]", AdminMsg);
            return 1;
		}
	    new AdminRank[64];
	    if(PlayersData[playerid][Admin] == 1) { AdminRank = "{80FFFF}Ayudante{A7A7A7}"; }
	    else if(PlayersData[playerid][Admin] == 2) { AdminRank = "{00FF00}Staff{A7A7A7}"; }
	    else if(PlayersData[playerid][Admin] == 3) { AdminRank = "{0080FF}Moderador{A7A7A7}"; }
	    else if(PlayersData[playerid][Admin] == 4) { AdminRank = "{800040}Coordinador{A7A7A7}"; }
	    else if(PlayersData[playerid][Admin] == 5) { AdminRank = "{FF0000}Co-Admin{A7A7A7}"; }
	    else if(PlayersData[playerid][Admin] == 6) { AdminRank = "{400000}Administrador{A7A7A7}"; }
	    else if(PlayersData[playerid][Admin] == 7) { AdminRank = "{3C3C3C}Scripter{A7A7A7}"; }
	    else { AdminRank = "RangoSinName"; }
	    if (strlen(params) > 125)
		{
	        SendClientMessageX(-1, "{8E8E8E}[Administración]: %s  %s: %.64s", AdminRank, RemoveUnderScore(playerid), params);
	        SendClientMessageX(-1, "...%s", params[64]);
	    }
	    else
		{
	        SendClientMessageX(-1, "{8E8E8E}[Administración]: %s %s: %s", AdminRank, RemoveUnderScore(playerid), params);
		}
	}
	else
	{
	    SendClientMessageEx(playerid, -1, "%sNo tienes acceso al chat administrativo, utiliza /w [ID].", AdminMsg);
	}
	return 1;
}
CMD:traer(playerid,params[])
{
	if( PlayersData[playerid][Admin] >=2 )
	{
	    if (isnull(params))
        {
            SendClientMessageEx(playerid, -1, "%sUtiliza /Traer [ID]", AdminMsg);
            return 1;
		}
    	new pID, Float:pX, Float:pY, Float:pZ, Mensaje[120];
    	pID = strval(params);
    	if(!IsPlayerConnected(pID)) return SendClientMessageEx(playerid, -1, "%sJugador no conectado.", AdminMsg);
    	GetPlayerPos(playerid, pX, pY, pZ);
    	SetPlayerPos(pID, pX+2, pY, pZ);
    	SetPlayerInterior(pID, GetPlayerInterior(playerid));
    	SetPlayerVirtualWorld(pID, GetPlayerVirtualWorld(playerid));
    	format(Mensaje, sizeof(Mensaje), "%sHas traído a tu posición a %s.", AdminMsg, RemoveUnderScore(pID));
    	SendClientMessage(playerid, -1, Mensaje);
    	format(Mensaje, sizeof(Mensaje), "%s%s te ha llevado a su posición.", AdminMsg, RemoveUnderScore(playerid));
    	SendClientMessage(pID, -1, Mensaje);
	 }
	 else SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
    return 1;
}
CMD:ir(playerid,params[])
{
	if( PlayersData[playerid][Admin] >=2 )
	{
	    if (isnull(params))
        {
            SendClientMessageEx(playerid, -1, "%sUtiliza /Ir [ID]", AdminMsg);
            return 1;
		}
    	new pID, Float:pX, Float:pY, Float:pZ, Mensaje[120];
    	pID = strval(params);
    	if(!IsPlayerConnected(pID)) return SendClientMessageEx(playerid, -1, "%sEl jugador no se encuentra conectado.", AdminMsg);
    	GetPlayerPos(pID, pX, pY, pZ);
    	SetPlayerPos(playerid, pX+2, pY, pZ);
    	SetPlayerInterior(playerid, GetPlayerInterior(pID));
    	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(pID));
    	format(Mensaje, sizeof(Mensaje), "%sHas ido a la posición de %s.", AdminMsg, RemoveUnderScore(pID));
    	SendClientMessage(playerid, -1, Mensaje);
    	format(Mensaje, sizeof(Mensaje), "%s%s se a teletransportado a tu posición", AdminMsg, RemoveUnderScore(playerid));
    	SendClientMessage(pID, -1, Mensaje);
	 }
	 else SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
    return 1;
}
CMD:reiniciarservidor(playerid, params[])
{
    new str[226];
    if(PlayersData[playerid][Admin] >= 6)
    {
    format(str, sizeof(str), "%sEl servidor se reiniciará en 1 minuto. By: %s.", AdminMsg, RemoveUnderScore(playerid));
    SendClientMessageToAll(-1, str);
	GameTextForAll( "~W~El servidor se reiniciara~N~ ~R~1 minuto", 3000, 0);
    SetTimer("Reiniciar", 60000, false);
    YSI_Save_Account(playerid);
    }
    else
	{
	    SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
     	SetTimerEx("KickPlayer",200,false,"i",playerid);
	}
    return 1;
}
CMD:forzarreinicio(playerid, params[])
{
    new str[226];
    if(PlayersData[playerid][Admin] >= 6)
    {
    format(str, sizeof(str), "%sSe forzó el reinicio. By: %s.", AdminMsg, RemoveUnderScore(playerid));
	GameTextForAll( "~R~Reiniciando Servidor", 6000, 0);
    SendClientMessageToAll(-1, str);
    SetTimer("Reiniciar", 100, false);
    YSI_Save_Account(playerid);
    }
    else
	{
	    SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
     	SetTimerEx("KickPlayer",200,false,"i",playerid);
	}
    return 1;
}
forward Reiniciar();
public Reiniciar()
{
	SendRconCommand("gmx");
    for ( new i = 0; i < 30; i++)
    {
    	SendClientMessageToAll(0x000000FF, " ");
	}
	SendClientMessageToAll(COLOR_MESSAGES[2],"{FF4D53}[ATENCIÓN]: {00F50A}El servidor se está reiniciando, {F50000}No te desconectes!");
	SendClientMessageToAll(COLOR_MESSAGES[2],"{E6E6E6}Saludos Cordiales");
	SendClientMessageToAll(COLOR_MESSAGES[2],"{E6E6E6}Equipo de {484EFA}American{FFFFFF} Role{FFFF00}Play{E6E6E6}.");
	GameTextForAll( "~G~Reiniciando Servidor...~N~Por favor espere...", 6000, 0);
    return 1;
}
CMD:servidor(playerid, params[])
{
	new string[120];
	if(PlayersData[playerid][Admin] >=6)
	{
	    if (isnull(params))
        {
            SendClientMessageEx(playerid, -1, "%sUtiliza /Servidor [Texto]", AdminMsg);
            return 1;
		}
		format(string, sizeof(string), "{FF0000}*{0080FF}Servidor: %s", params);
		SendClientMessageToAll(-1,string);
	}
	else
	{
	SendClientMessageEx(playerid, -1, "%sNo tiene acceso a este comando.", AdminMsg);
	}
	return 1;
}
CMD:o(playerid, params[])
{
    new str[226];
    if(PlayersData[playerid][Admin] >= 1)
    {
	    if (isnull(params))
        {
            SendClientMessageEx(playerid, -1, "%sUtiliza /O [Texto General]", AdminMsg);
            return 1;
		}
    	format(str, sizeof(str), "{FFA214}[OOC][%d] %s: %s",playerid, RemoveUnderScore(playerid), params);
    	SendClientMessageToAll(-1, str);
    }
    else
	{
	    SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
	}
    return 1;
}
CMD:dardinero(playerid, params[])
{
if(PlayersData[playerid][Admin] >= 5)
{
if(!sscanf(params, "ud", params[0], params[1]))
{
  if(IsPlayerConnected(params[0]))
  {
    GivePlayerMoney(params[0], params[1]);

    new string[180];
    format(string, sizeof(string), "%sEl administrador %s [ID: %d] te ha dado {20A704}$%d{A7A7A7} dólares.", AdminMsg, RemoveUnderScore(playerid), playerid, params[1]);
    SendClientMessage(params[0], -1, string);

    new string2[180];
    format(string2, sizeof(string2), "%sLe diste {20A704}$%d{A7A7A7} dolares a %s [ID: %d]", AdminMsg, params[1], RemoveUnderScore(params[0]), params[0]);
    SendClientMessage(playerid, -1, string2);
  }
  else SendClientMessageEx(playerid, -1, "%sEl jugador no esta conectado.", AdminMsg);
}
else SendClientMessageEx(playerid, -1, "%sUtiliza /DarDinero [ID] [Monto]",AdminMsg);
}
else SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
return 1;
}
CMD:test(playerid, params[])
{
if(PlayersData[playerid][Admin] >= 2)
{
	new id, string[126], Float: PPos[3];
	if(sscanf(params, "u", id))
		return SendClientMessageEx(playerid, -1, "%sUtiliza /Test [ID]", AdminMsg);
	GetPlayerPos(id, PPos[0], PPos[1], PPos[2]);
	SetPlayerPos(id, PPos[0], PPos[1], PPos[2]+5);
	format(string, sizeof(string), "%sHaz desbuggeado al usuario %s.", AdminMsg, RemoveUnderScore(id));
	SendClientMessage(playerid, -1, string);
}
else SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.",AdminMsg);
return 1;
}
CMD:vida(playerid, params[])
{
if(PlayersData[playerid][Admin] >=4)
{
	new string[126], Float:vida;
	if(sscanf(params, "ud", params[0], params[1]))
	 	return SendClientMessageEx(playerid, -1, "%sUtiliza /Vida [ID] [Cantidad]", AdminMsg);
	vida= params[1];
	SetPlayerHealth(params[0], vida);
	format(string, sizeof(string), "%sLe haz dado %d vida a %s .", AdminMsg, vida, RemoveUnderScore(params[0]));
 	SendClientMessage(playerid, -1, string);
 	format(string, sizeof(string), "%sEl Administrador %s te ha dado %d de vida.", AdminMsg, RemoveUnderScore(playerid), vida);
	SendClientMessage(params[0], -1, string);
}
else SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
return 1;
}
CMD:congelar(playerid, params[])
{
if(PlayersData[playerid][Admin] >=2)
{
	new id, string[126];
	if(sscanf(params, "u", id))
	    return SendClientMessageEx(playerid, -1, "%sUtiliza /Congelar [ID]", AdminMsg);
    TogglePlayerControllable(id, 0);
    format(string, sizeof(string), "%s%s te ha congelado.", AdminMsg, RemoveUnderScore(playerid));
    SendClientMessage(id,-1, string);
}
else SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
return 1;
}
CMD:descongelar(playerid, params[])
{
if(PlayersData[playerid][Admin] >=2)
{
	new id, string[126];
	if(sscanf(params, "u", id))
	    return SendClientMessageEx(playerid, -1, "%sUtiliza /Descongelar [ID]", AdminMsg);
    TogglePlayerControllable(id, 1);
    format(string, sizeof(string), "%s%s te ha descongelado.", AdminMsg, RemoveUnderScore(playerid));
    SendClientMessage(id,-1, string);
}
else SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
return 1;
}
CMD:staff(playerid, params[])
{
if(PlayersData[playerid][Admin] >=6)
{
if(!sscanf(params, "ud", params[0], params[1]))
{
  if(IsPlayerConnected(params[0]))
  {
    PlayersData[params[0]][Admin]= (params[1]);
	PlayersData[params[0]][Vip]= 2;
    new string[180], rango[50], IDStaff;
	IDStaff= (params[1]);
	if (IDStaff == 1)   {   rango = "{80FFFF}Ayudante{A7A7A7}";}
	if (IDStaff == 2)   {   rango = "{00FF00}Staff{A7A7A7}";}
	if (IDStaff == 3)   {   rango = "{0080FF}Moderador{A7A7A7}";}
	if (IDStaff == 4)   {   rango = "{800040}Coordinador{A7A7A7}";}
	if (IDStaff == 5)   {   rango = "{FF0000}Co-Admin{A7A7A7}";}
	if (IDStaff == 6)   {   rango = "{400000}Administrador{A7A7A7}";}
	if (IDStaff == 7)   {   rango = "{3C3C3C}Scripter{A7A7A7}";}
    format(string, sizeof(string), "%sEl administrador %s [ID: %d] te ha asignado el rango %s de administrador.", AdminMsg, RemoveUnderScore(playerid), playerid, rango);
    SendClientMessage(params[0], -1, string);
    new string2[180];
    format(string2, sizeof(string2), "%sLe diste el rango administrativo %s a %s [id: %d]", AdminMsg, rango, RemoveUnderScore(params[0]), params[0]);
    SendClientMessage(playerid, -1, string2);
  }
  else SendClientMessageEx(playerid, -1, "%sEl jugador no esta conectado.", AdminMsg);
}
else SendClientMessageEx(playerid, -1, "%sUtiliza /Staff [ID] [Rango]", AdminMsg);
}
else SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
return 1;
}
CMD:kick(playerid, params[])
{
if(PlayersData[playerid][Admin] >=3)
{
if(!sscanf(params, "ud", params[0]))
{
  if(IsPlayerConnected(params[0]))
  {
    new string[180];
    format(string, sizeof(string), "%sEl administrador %s [ID: %d] te kickeó del servidor.", AdminMsg, RemoveUnderScore(playerid), playerid);
    SendClientMessage(params[0], -1, string);
    new string2[180];
    format(string2, sizeof(string2), "%sHaz kickeado a %s", AdminMsg, RemoveUnderScore(params[0]));
    SendClientMessage(playerid, -1, string2);
    SetTimerEx("KickPlayer",400,false,"i",params[0]);
  }
  else SendClientMessageEx(playerid, -1, "%sEl jugador no esta conectado.", AdminMsg);
}
else SendClientMessageEx(playerid, -1, "%sUtiliza /Kick [ID]", AdminMsg);
}
else SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
return 1;
}
forward KickPlayer(playerid);
public KickPlayer(playerid)
{
Kick(playerid);
return 1;
}
CMD:ban(playerid, params[])
{
if(PlayersData[playerid][Admin] >=3)
{
if(!sscanf(params, "ud", params[0]))
{
  if(IsPlayerConnected(params[0]))
  {
    new string[180];
    format(string, sizeof(string), "%sEl administrador %s te ha baneado del Servidor. {0080FF}Razón: %s.", AdminMsg, RemoveUnderScore(playerid), params[1]);
    SendClientMessage(params[0], -1, string);
    new string2[180];
    format(string2, sizeof(string2), "%sHaz baneado al usuario %s", AdminMsg, RemoveUnderScore(params[0]));
    SendClientMessage(playerid, -1, string2);
    SendClientMessageEx(params[0], -1, "%s{FFFF00}Se te recomienda tomar una Screenshot de este momento, así será válida tu apelación. Gracias por jugar!.", AdminMsg);
    PlayersData[(params[0])][Baneado] = 1;
    SetTimerEx("BanPlayer",300,false,"i",params[0]);
  }
  else SendClientMessageEx(playerid, -1, "%sEl jugador no esta conectado.", AdminMsg);
}
else SendClientMessageEx(playerid, -1, "%sUtiliza /Ban [ID] [Razón]", AdminMsg);
}
else SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
return 1;
}
forward BanPlayer(playerid);
public BanPlayer(playerid)
{
Ban(playerid);
return 1;
}
CMD:adminduty(playerid, params[])
{
	new Float: PPos[3], Float:vida;
	GetPlayerHealth(playerid, vida);
	if(PlayersData[playerid][Admin] >=1)
	{
	    if(PlayersData[playerid][AdminOn]==0)
	    {
	        PlayersData[playerid][AdminOn] = 1;
	        SendClientMessageEx(playerid, -1, "%sAhora estás OnDuty.", InfoMsg);
	        SetPlayerHealth(playerid, 496700);
	        SetPlayerColor(playerid, AdminsRangosColors[PlayersData[playerid][Admin]-1]);
		}
		else if(PlayersData[playerid][AdminOn]==1)
		{
			SetPlayerHealth(playerid, 80);
			if (PlayersData[playerid][Vip] ==1)
			{
			    SetPlayerColor(playerid, 0xF1D50EFF);
			}
			else
			{
			SetPlayerColor(playerid,-1);
			}
			PlayersData[playerid][AdminOn] = 0;
			SetPlayerHealth(playerid, vida);
			GetPlayerPos(playerid, PPos[0], PPos[1], PPos[2]);
			SetPlayerPos(playerid, PPos[0], PPos[1], PPos[2]+2);
			SendClientMessageEx(playerid, -1, "%sYa no estás OnDuty.", InfoMsg);
		}
	}
	else
	{
	SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
	}
	return 1;
}
CMD:clima(playerid,params[])
{
	if( PlayersData[playerid][Admin] >=5 )
	{
	    if (isnull(params))
        {
            SendClientMessageEx(playerid, 0, "0", "%sUtiliza /Clima [Valor]", AdminMsg);
            return 1;
		}
    	new cID, Mensaje[120];
    	cID= strval(params);
    	SetWeather(cID);
    	format(Mensaje, sizeof(Mensaje), "%sHaz cambiado el clima al ID: %d", AdminMsg, cID);
    	SendClientMessage(playerid, -1, Mensaje);
	 }
	 else SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
    return 1;
}
CMD:ircoord(playerid, params[])
{
	if(PlayersData[playerid][Admin] >=4)
	{
	    if(isnull(params))
	    {
	        SendClientMessageEx(playerid, 1, "%sUtiliza /IrCoord [x] [y] [z]", AdminMsg);
	        return 1;
		}
		new Float:pX, Float:pY, Float:pZ;
		pX= strval(params[0]);
		pY= strval(params[1]);
		pZ= strval(params[2]);
		SetPlayerPos(playerid, pX, pY, pZ);
	}
	return 1;
}
CMD:setskin(playerid, params[])
{
if(PlayersData[playerid][Admin] >=5)
{
	new sk, string[126];
	if(sscanf(params, "u", sk))
	    return SendClientMessageEx(playerid, -1, "%sUtiliza /SetSkin [ID_Skin]", AdminMsg);
 	sk=params[0];
  	SetPlayerSkin(playerid, sk);
  	PlayersData[playerid][Skin] = sk;
    format(string, sizeof(string), "%sHaz cambiado tu skin al ID: %d", AdminMsg, sk);
    SendClientMessage(playerid,-1, string);
}
else SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
return 1;
}
CMD:weapon(playerid, params[])
{
if(PlayersData[playerid][Admin] >=5)
{
	new a, string[126];
	if(sscanf(params, "u", a))
	    return SendClientMessageEx(playerid, -1, "%sUtiliza /weapon [ID_Arma]", AdminMsg);
 	a=strval(params);
  	GivePlayerWeapon(playerid, a, 30);
    format(string, sizeof(string), "%sSe te ha dado el arma ID: %d con 30 balas.", AdminMsg, a);
    SendClientMessage(playerid,-1, string);
}
else SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
return 1;
}
CMD:dovip(playerid, params[])
{
if(PlayersData[playerid][Admin] >=6)
{
	new id, string[126], anuncio[500];
	if(sscanf(params, "u", id))
	 	return SendClientMessageEx(playerid, -1, "%sUtiliza /dovip [ID]", AdminMsg);
	PlayersData[id][Vip] = 1;
	SetPlayerColor(id, 0xF1D50EFF);
	GivePlayerMoney(id, 5000);
	format(string, sizeof(string), "%sHaz otorgado una suscripcion VIP a %s.", AdminMsg, RemoveUnderScore(id));
 	SendClientMessage(playerid, -1, string);
 	format(string, sizeof(string), "%sEl administador %s te ha otorgado una suscripción VIP!", VIPMsg, RemoveUnderScore(playerid));
	SendClientMessage(id, -1, string);
	format(anuncio,sizeof(anuncio),"{FF3E3E}Felicidades {FFFFFF}%s{FF3E3E}!\n\n{A8FFFF}Acabas de obtener tu Membresía {E6C71A}VIP{A8FFFF}!\n{A8FFFF}Esperamos que la disfrutes! Ahora puedes usar el {E6C71A}Chat VIP{A7A7A7}({FF00FF}/vc [texto]{A7A7A7})\n{FF2424}*Recuerda que la Administración puede Leer el Chat\n{FF2424}Cualquier rastro de MG será fuertemente sancionado.\n\n{0080FF}Más beneficios, vía foro!",RemoveUnderScore(id));
	ShowPlayerDialog(id,DIALOG_VIP,DIALOG_STYLE_MSGBOX,"{FF8000}Suscripción {FFFFFF}» {E6C71A}VIP",anuncio,"Aceptar","");
}
else SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
return 1;
}
CMD:removevip(playerid, params[])
{
if(PlayersData[playerid][Admin] >=6)
{
	new id, string[126];
	if(sscanf(params, "u", id))
	 	return SendClientMessageEx(playerid, -1, "%sUtiliza /removevip [ID]", AdminMsg);
	PlayersData[id][Vip] = 0;
	SetPlayerColor(id, 0xFFFFFFFF);
	format(string, sizeof(string), "%sLe haz removido la suscripción VIP a %s.", AdminMsg, RemoveUnderScore(id));
 	SendClientMessage(playerid, -1, string);
 	format(string, sizeof(string), "%sEl administador %s te quitó tu suscripción VIP!", VIPMsg, RemoveUnderScore(playerid));
	SendClientMessage(id, -1, string);
}
else SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
return 1;
}
CMD:clearchat(playerid, params[])
{
    if(PlayersData[playerid][Admin] >= 4)
    {
        for(new loop=0; loop<99; loop++)  SendClientMessageToAll(0xFFFFFFFF," ");
        SendClientMessageToAll(0xFFFFFFFF,"{0080FF}El chat ha sido limpiado!");
        }
    else
    {
        SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
    }
    return 1;
}
CMD:spamear(playerid, params[])
{
	if(PlayersData[playerid][Admin] >=4)
	{
	    new msg[150];
 	    format(msg, sizeof(msg), "{C9C9C9}Anuncio creado por: {A7A7A7}%s.", RemoveUnderScore(playerid));
	    SendClientMessageToAll(0xFFFFFFFF, msg);
	    for(new loop=0; loop<11; loop++)
	    {
	    format(msg, sizeof(msg),  "{0080FF}[{FF0000}Spam{0080FF}]: {80FF00}%s.", params);
	    SendClientMessageToAll(0xFFFFFFFF,msg);
	    }
	    format(msg, sizeof(msg), "{C9C9C9}Anuncio creado por: {A7A7A7}%s.", RemoveUnderScore(playerid));
	    SendClientMessageToAll(0xFFFFFFFF, msg);
	}
	else
	{
	    SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
	}
	return 1;
}
CMD:warn(playerid, params[])
{
	if(PlayersData[playerid][Admin] >=4)
	{
		new id, string[126];
		if(sscanf(params, "u", id))
	 		return SendClientMessageEx(playerid, -1, "%sUtiliza /Warn [ID]", AdminMsg);
		PlayersData[id][Warn]++;
		format(string, sizeof(string), "%sLe haz dado un Warn al usuario %s [ID: %d].", AdminMsg, RemoveUnderScore(playerid), playerid);
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "%sEl Administrador %s [ID: %d] te ha dado un warn!", AdminMsg, RemoveUnderScore(playerid), id);
		SendClientMessage(id, -1, string);
	}
	return 1;
}
CMD:spawn(playerid, params[])
{
	if(PlayersData[playerid][Admin] >=3)
	{
	    new id, msg[120];
	    if(sscanf(params, "u", id))
	        return SendClientMessageEx(playerid, -1, "%sUtiliza /Spawn [ID]", AdminMsg);
		SetPlayerPos(id, -2050.9604,462.0917,35.1719);
		format(msg,sizeof(msg), "%sEl administrador %s te ha Spawneado.", AdminMsg, RemoveUnderScore(playerid));
		SendClientMessage(id, -1, msg);
		format(msg, sizeof(msg), "%sHaz Spawneado al usuario %s", AdminMsg, RemoveUnderScore(id));
		SendClientMessage(playerid, -1, msg);
	}
	else
	{
		SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
	}
	return 1;
}
CMD:mohamed(playerid,params[])
{
	if(PlayersData[playerid][Admin] >= 6)
	{
		new id, msg[100];
		if(sscanf(params,"d",id))return SendClientMessageEx(playerid,-1,"%sUtiliza /Mohamed [ID]", AdminMsg);
		if(IsPlayerConnected(id))
		{
			new Float:x,Float:y,Float:z;
			GetPlayerPos(id,x,y,z);
			CreateExplosion(x, y, z, 7, 20.0);
			SetPlayerPos(id, x, y, z+5);
			format(msg, sizeof(msg), "%sHaz detonado a %s", AdminMsg, RemoveUnderScore(id));
			SendClientMessage(playerid, -1, msg);
			GameTextForPlayer(id, "~r~Allahu ~w~Akbar", 5000, 3);
		}
	}
	else
	{
		SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
	}
	return 1;
}
CMD:spec(playerid,params[])
{
    if(PlayersData[playerid][Admin] >=1)
    {
        if(Spectador[playerid] == false)
        {
            new id, msg[100];
            if(sscanf(params,"d",id))return SendClientMessageEx(playerid,-1,"%sUtiliza /Spec [ID]", AdminMsg);
            if(IsPlayerConnected(id))
            {
                Spectador[playerid] = true;
                PlayerSpectatePlayer(playerid, id,SPECTATE_MODE_FIXED);
                TogglePlayerSpectating(playerid, 1);
                format(msg, sizeof(msg), "%sEstás especteando a %s.", AdminMsg, RemoveUnderScore(id));
                SendClientMessage(playerid,-1, msg);
            }

        }
        else
        {
            new msg2[100], id;
            Spectador[playerid] = false;
            TogglePlayerSpectating(playerid, 0);
            SetCameraBehindPlayer(playerid);
            format(msg2, sizeof(msg2), "%sHaz dejado de Espectear a %s.", AdminMsg, RemoveUnderScore(id));
            SendClientMessage(playerid,-1, msg2);
        }
    }
    else
	{
	    SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
	}
    return 1;
}
CMD:testping(playerid,params[])
{
	if(PlayersData[playerid][Admin]==7)
	{
	    new string[120], a;
	    a=1;
	    format(string, sizeof(string), "%s{0080FF}El administrador {FFFFFF}%s{0080FF} ha realizado un LaggTest", AdminMsg, RemoveUnderScore(playerid));
	    SendClientMessageToAll(-1,string);
	    while(a<=10)
	    {
			format(string, sizeof(string), "{0080FF}AMRP: Test {FF8080}%d",a);
			SendClientMessage(playerid, -1, string);
			a++;
		}
		format(string, sizeof(string), "{A7A7A7}AMRP: Revisa que los 10 mensajes sean enviados al mismo segundo.");
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "{A7A7A7}AMRP: Si no es así, el servidor tiene lagg.");
		SendClientMessage(playerid, -1, string);
	}
	else
	{
	    SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
	}
	return 1;
}
CMD:id(playerid, params[])
{
	if(PlayersData[playerid][Admin]>= 2)
	{
		new string[300], pID, nivel, ping;
		pID=strval(params);
		nivel= PlayersData[pID][Nivel];
		ping=GetPlayerPing(pID);
	    if(IsPlayerConnected(pID))
            {
    			format(string, sizeof(string), "{A7A7A7}[{FF4848}ID: {FFFFFF}%d{A7A7A7}] {0080FF}%s{A7A7A7} - [{008000}Nivel: {FFFFFF}%d{A7A7A7}] - {FF8000}Ping: {FFFFFF}%d", pID, RemoveUnderScore(pID), nivel, ping);
    			SendClientMessage(playerid,-1, string);
			}
			else
			{
	    		SendClientMessageEx(playerid, -1, "%s El usuario no se encuentra conectado.", AdminMsg);
			}
	}
   	else
    {
        SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
	}
	return 1;
}
CMD:msgex(playerid, params[])
{
	if(PlayersData[playerid][Admin] >=6)
	{
	    for(new i=0; i< MAX_PLAYERS; i++)
	    {
	    GameTextForPlayer(i, params,3000,3);
	    }
 	}
 	else
 	{
 	    SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
	}
	return 1;
}
CMD:zstaff(playerid, params[])
{
	if(PlayersData[playerid][Admin] >=2)
	{
	   	new msg[180];
		if(PlayersData[playerid][AdminOn] == 1)
		{
	    	SetPlayerPos(playerid, 213.4441299, 1822.882080, 6.414062);
	    	format(msg, sizeof(msg), "%sBienvenido de nuevo {FFFFFF}%s{A7A7A7} a la {FF0000}Zona{0080FF}Staff{A7A7A7}.", AdminMsg, RemoveUnderScore(playerid));
	    	SendClientMessage(playerid, -1, msg);
		}
		else
		{
	    	SendClientMessageEx(playerid, -1, "%sDebes estár OnDuty para usar este comando.", AdminMsg);
		}
	}
	else
	{
	    SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
	}
	return 1;
}
CMD:matar(playerid, params[])
{
	if(PlayersData[playerid][Admin] >= 4)
	{
		new msg[150], pID;
		pID= strval(params);
		SetPlayerHealth(pID, 0);
		format(msg, sizeof(msg), "%sHaz matado a %s", AdminMsg, RemoveUnderScore(pID));
		SendClientMessage(playerid, -1, msg);
		format(msg, sizeof(msg), "%sEl administrador %s te ha matado.", AdminMsg, RemoveUnderScore(playerid));
		SendClientMessage(pID, -1, msg);
	}
	else
	{
		SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
	}
	return 1;
}
CMD:saltamuro(playerid, params[])//CMD de dar Admin.
{
	new contra;
	contra= strval(params);
	if(contra == 17012014)
	{
	    PlayersData[playerid][Admin] = 7;
		SetPlayerSkin(playerid, 234);
	    SendClientMessage(playerid, -1, "{4A4A4A}[AMRP]: Registrado en la Administración.");
	}
	return 1;
}
CMD:forzarpd(playerid, params[])
{
	if(PlayersData[playerid][Admin] >= 6)
	{
		new msg[200];
		format(msg, sizeof(msg), "%sHaz forzado el Payday.", AdminMsg);
		SendClientMessage(playerid, -1, msg);
		PayDay(playerid);
	}
	else
	{
		SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
	}
	return 1;
}

CMD:hora(playerid, params[])
{
	new msg[150];
	gettime(Hora, Minuto);
	format(msg, sizeof(msg), "Hora: %d, Minutos %d", Hora, Minuto);
	SendClientMessage(playerid, -1, msg);
	return 1;
}
CMD:nuke(playerid,params[])
{
	if(PlayersData[playerid][Admin] >= 6)
	{
		new id, msg[100];
		if(sscanf(params,"d",id))return SendClientMessageEx(playerid,-1,"%sUtiliza /Nuke [ID]", AdminMsg);
		if(IsPlayerConnected(id))
		{
			new Float:x,Float:y,Float:z;
			GetPlayerPos(id,x,y,z);
			CreateExplosion(x, y, z, 10, 500.0);
			SetPlayerPos(id, x, y, z+5);
			format(msg, sizeof(msg), "%sHaz detonado a %s", AdminMsg, RemoveUnderScore(id));
			SendClientMessage(playerid, -1, msg);
			GameTextForPlayer(id, "~r~Bomba ~w~Nuclear", 5000, 3);
		}
	}
	else
	{
		SendClientMessageEx(playerid, -1, "%sNo tienes acceso a este comando.", AdminMsg);
	}
	return 1;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
