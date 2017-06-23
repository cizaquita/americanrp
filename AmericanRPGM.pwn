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
#define COLOR_BLANCO 0xffffffff
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
new bool:Intentar[MAX_PLAYERS];
new MotorAuto[MAX_VEHICLES];
new bool:Spectador[MAX_PLAYERS];
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
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* ---===[- COLORES -]===--- */
#define C_Blanco         0xFFFFFFFF
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
	Faccion, //0 - 1 DESACTIVADO ACTUAL.
	Rango, //0 - 6 DESACTIVADO ACTUAL.
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
        SendInfoMessage(playerid, 2, "0", "El hospital te ha costado $200");
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
    TextDrawShowForPlayer(playerid, Textdraw0);
    TextDrawShowForPlayer(playerid, Textdraw1);
    TextDrawShowForPlayer(playerid, Textdraw2);
    TextDrawShowForPlayer(playerid, Textdraw3);
    TextDrawShowForPlayer(playerid, Textdraw4);
    TextDrawShowForPlayer(playerid, Textdraw5);
    TextDrawShowForPlayer(playerid, Textdraw6);
    TextDrawShowForPlayer(playerid, Textdraw7);
    TextDrawShowForPlayer(playerid, Textdraw8);
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
    TextDrawHideForPlayer(playerid, Textdraw0);
    TextDrawHideForPlayer(playerid, Textdraw1);
    TextDrawHideForPlayer(playerid, Textdraw2);
    TextDrawHideForPlayer(playerid, Textdraw3);
    TextDrawHideForPlayer(playerid, Textdraw4);
    TextDrawHideForPlayer(playerid, Textdraw5);
    TextDrawHideForPlayer(playerid, Textdraw6);
    TextDrawHideForPlayer(playerid, Textdraw7);
    TextDrawHideForPlayer(playerid, Textdraw8);
    TextDrawShowForPlayer(playerid, Textdraw9);
    TextDrawShowForPlayer(playerid, Textdraw10);
    TextDrawShowForPlayer(playerid, Textdraw11);
	return 1;
}
public OnPlayerDisconnect(playerid, reason)
{
	YSI_Save_Account(playerid);
 	new text[180];
  	format(text, 180, "{A7A7A7}[Administración]: %s se ha desconectado del Servidor.", RemoveUnderScore(playerid));
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
    DetectorCercania(20.0, playerid, string, 0xE6E6E6E6,0xC8C8C8C8,0xAAAAAAAA,0x8C8C8C8C,0x6E6E6E6E);
    SetPlayerChatBubble(playerid, text, -1, 7.0, 15000);
    return 0;
}
public OnPlayerUpdate(playerid)
{
	return 1;
}
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
       new IDAuto = GetPlayerVehicleID(playerid);//define que IDAuto es la id del auto
       if(newkeys == KEY_FIRE)//Para que encendiera seria el click osea KEY_FIRE
       {
        if(IsPlayerInAnyVehicle(playerid))//si esta en un vehiculo
            {
            if(MotorAuto[IDAuto] == 0)//si el motor esta apagado
            {
          SetTimerEx("EncenderMotor", 500, false, "d", playerid);//timer para encender el vehiculo [2500 = 2,5 segundos]
          GameTextForPlayer(playerid, "~w~Encendiendo...",2000,3);//mensaje que dice que el motor se esta encendiendo
		  new string[128 + MAX_PLAYER_NAME];
		  format(string, sizeof(string), "*%s inserta la llave en el switch y la gira levemente!", RemoveUnderScore(playerid));
    	  DetectorCercania(30.0, playerid, string, 0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA);
         }
			else
         {
          SetTimerEx("ApagarMotor", 500, false, "d", playerid);//tiempo en apagar el motor [1500 = 1,5 segundos]
          GameTextForPlayer(playerid, "~w~Apagando...",1000,3);//mensaje que dice que el motor se esta apagando
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
            new IDAuto = GetPlayerVehicleID(playerid);//define que IDAuto es la id del auto
       		new enginem, lights, alarm, doors, bonnet, boot, objective;//define las cosas del auto
       		GetVehicleParamsEx(GetPlayerVehicleID(playerid),enginem, lights, alarm, doors, bonnet, boot, objective);

       		SetVehicleParamsEx(GetPlayerVehicleID(playerid),VEHICLE_PARAMS_ON, lights, alarm, doors, bonnet, boot, objective);//deja el auto con las luces encendidas, motor, etc.
       		GameTextForPlayer(playerid, "~w~Motor ~g~Encendido",1000,3);//mensaje de encendido
       		MotorAuto[IDAuto] = 1;//deja el motor encendido
    		new string[128 + MAX_PLAYER_NAME];
    		format(string, sizeof(string), "**Vehículo encendido [ID:%d]", playerid);
    		DetectorCercania(30.0, playerid, string, 0xFFFF00FF,0xFFFF00FF,0xFFFF00FF,0xFFFF00FF,0xFFFF00FF);
    }
public ApagarMotor(playerid)
    {
        new IDAuto = GetPlayerVehicleID(playerid);
    	new enginem, lights, alarm, doors, bonnet, boot, objective;
       	GetVehicleParamsEx(GetPlayerVehicleID(playerid),enginem, lights, alarm, doors, bonnet, boot, objective);

       	SetVehicleParamsEx(GetPlayerVehicleID(playerid),VEHICLE_PARAMS_OFF, lights, alarm, doors, bonnet, boot, objective);//deja el motor y las demas cosas apagadas
       	GameTextForPlayer(playerid, "~w~Motor ~r~Apagado",1000,3);//mensaje de apagado
       	MotorAuto[IDAuto] = 0;//deja el motor apagado
		new string[128 + MAX_PLAYER_NAME];
 		format(string, sizeof(string), "**Vehículo apagado [ID:%d]", playerid);
		DetectorCercania(30.0, playerid, string, 0xFFFF00FF,0xFFFF00FF,0xFFFF00FF,0xFFFF00FF,0xFFFF00FF);
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
	if (GetPlayerVehicleSeat(playerid)==0){
	if(MotorAuto[vehicleid] == 0)
	{
		SendClientMessage(playerid,C_Blanco,"{FF4D53}[Info]: Este coche está apagado! presiona Alt para encenderlo.");
	}
	if(MotorAuto[vehicleid] == 1)
	{
		SendClientMessage(playerid,C_Blanco,"{FF4D53}[Info]: Este coche está encendido! presiona Alt para apagarlo.");
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
			    PlayersData[playerid][Dinero]   = PLAYER_START_MONEY;
			    PlayersData[playerid][Estado]   =   0;
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

	Textdraw5 = TextDrawCreate(150.500000, 36.711116, "American");
	TextDrawLetterSize(Textdraw5, 0.920000, 5.053334);
	TextDrawAlignment(Textdraw5, 1);
	TextDrawColor(Textdraw5, 41215);
	TextDrawSetShadow(Textdraw5, 3);
	TextDrawSetOutline(Textdraw5, 0);
	TextDrawBackgroundColor(Textdraw5, 51);
	TextDrawFont(Textdraw5, 1);
	TextDrawSetProportional(Textdraw5, 1);

	Textdraw6 = TextDrawCreate(300.000000, 60.977748, "Role");
	TextDrawLetterSize(Textdraw6, 0.824998, 4.462223);
	TextDrawAlignment(Textdraw6, 1);
	TextDrawColor(Textdraw6, -1);
	TextDrawSetShadow(Textdraw6, 5);
	TextDrawSetOutline(Textdraw6, 0);
	TextDrawBackgroundColor(Textdraw6, 51);
	TextDrawFont(Textdraw6, 1);
	TextDrawSetProportional(Textdraw6, 1);

	Textdraw7 = TextDrawCreate(361.500000, 60.355552, "Play");
	TextDrawLetterSize(Textdraw7, 0.779999, 4.711108);
	TextDrawAlignment(Textdraw7, 1);
	TextDrawColor(Textdraw7, -5963521);
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

	Textdraw9 = TextDrawCreate(496.000000, 4.977838, "American");
	TextDrawLetterSize(Textdraw9, 0.313500, 1.139555);
	TextDrawAlignment(Textdraw9, 1);
	TextDrawColor(Textdraw9, 65535);
	TextDrawSetShadow(Textdraw9, 0);
	TextDrawSetOutline(Textdraw9, 1);
	TextDrawBackgroundColor(Textdraw9, 51);
	TextDrawFont(Textdraw9, 1);
	TextDrawSetProportional(Textdraw9, 1);

	Textdraw10 = TextDrawCreate(550.000000, 3.733332, "Role");
	TextDrawLetterSize(Textdraw10, 0.317000, 1.450666);
	TextDrawAlignment(Textdraw10, 1);
	TextDrawColor(Textdraw10, -1);
	TextDrawSetShadow(Textdraw10, 0);
	TextDrawSetOutline(Textdraw10, 1);
	TextDrawBackgroundColor(Textdraw10, 51);
	TextDrawFont(Textdraw10, 1);
	TextDrawSetProportional(Textdraw10, 1);

	Textdraw11 = TextDrawCreate(573.000000, 4.355556, "Play");
	TextDrawLetterSize(Textdraw11, 0.317000, 1.450666);
	TextDrawAlignment(Textdraw11, 1);
	TextDrawColor(Textdraw11, -5963521);
	TextDrawSetShadow(Textdraw11, 0);
	TextDrawSetOutline(Textdraw11, 1);
	TextDrawBackgroundColor(Textdraw11, 51);
	TextDrawFont(Textdraw11, 1);
	TextDrawSetProportional(Textdraw11, 1);
	return 1;
}
public OnGameModeExit()
{
	return 1;
}
public RemoverMapeos(playerid)
{
return 1;
}
public CargarMapeos()
{
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
		SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Se te ha transportado hasta el punto en el mapa.");
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
    	format(Mensaje, sizeof(Mensaje), "{A7A7A7}[Administración]: Has ido a la posición de %s", RemoveUnderScore(clickedplayerid));
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
    if(isnull(params)) return SendClientMessage(playerid, -1, "{FF4D53}[Administración]: Utiliza /me <acción>");
    new string[128 + MAX_PLAYER_NAME];
    format(string, sizeof(string), "*%s %s", RemoveUnderScore(playerid), params);
    DetectorCercania(15.0, playerid, string, 0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA,0xC2A2DAAA);
    return 1;
}
CMD:susurrar(playerid, params[])//COMANDO /Susurrar
{
    if(isnull(params)) return SendClientMessage(playerid, -1, "{FF4D53}[Administración]: Utiliza /Susurrar <texto>");
    new string[128 + MAX_PLAYER_NAME];
    format(string, sizeof(string), "%s susurra: %s", RemoveUnderScore(playerid), params);
    DetectorCercania(5.0, playerid, string, 0xBB00BBFF,0xBB00BBFF,0xBB00BBFF,0xBB00BBFF,0xBB00BBFF);
    return 1;
}
CMD:ame(playerid, params[])//COMANDO /Ame
{
    if(isnull(params)) return SendClientMessage(playerid, -1, "{FF4D53}[Administración]: Utiliza /ame <entorno>");
    new string[128 + MAX_PLAYER_NAME];
    format(string, sizeof(string), "**%s [ID:%d]", params, playerid);
    DetectorCercania(15.0, playerid, string, 0xFFFF00FF,0xFFFF00FF,0xFFFF00FF,0xFFFF00FF,0xFFFF00FF);
    return 1;
}
CMD:intentar(playerid, params[])//COMANDO /Intentar
{
    if(Intentar[playerid] == false) return SendClientMessage(playerid, -1, "{A7A7A7}** Debes esperar 10 segundos para volver a utilizar el comando.");
    if(isnull(params)) return SendClientMessage(playerid, 1, "{FF4D53}[Administración]: Utiliza /intentar <texto>");
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
    if(isnull(params)) return SendClientMessage(playerid, -1, "{FF4D53}[Administración]: Utiliza /Gritar <Grito>");
    new string[128 + MAX_PLAYER_NAME];
    format(string, sizeof(string), "%s grita: %s!!!", RemoveUnderScore(playerid), params);
    DetectorCercania(20.0, playerid, string, 0xE6E6E6E6,0xC8C8C8C8,0xAAAAAAAA,0x8C8C8C8C,0x6E6E6E6E);
    return 1;
}
CMD:b(playerid, params[])//COMANDO /B
{
    if(isnull(params)) return SendClientMessage(playerid, -1, "{FF4D53}[Administración]: Utiliza /B <texto>");
    new string[128 + MAX_PLAYER_NAME];
    format(string, sizeof(string), "[OOC]%s: (( %s ))", RemoveUnderScore(playerid), params);
    DetectorCercania(15.0, playerid, string, 0xE6E6E6E6,0xC8C8C8C8,0xAAAAAAAA,0x8C8C8C8C,0x6E6E6E6E);
    return 1;
}
CMD:pasaporte(playerid, params[])//COMANDO /Pasaporte
{
	if (isnull(params))
 	{
  		SendInfoMessage(playerid, 0, "0", "{A7A7A7}[Administración]: Utiliza /Pasaporte [ID]");
    	return 1;
	}
	new pID, string[300], string2[150], ciudad[15], sexo[10], edad, trabajo[20], cargo[15], relacion[30];
	pID=strval(params);
	if(!IsPlayerConnected(pID)) return SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Jugador no conectado.");
    if(ProxDetectorS(8.0, playerid, params[0]) || pID == playerid)
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
        format(string2, sizeof(string2), "{C2A2DA}* %s mira su pasaporte", RemoveUnderScore(playerid));
		format(string, sizeof(string), "{FF8040}Nombre: {FFFFFF}%s\n{FF8040}Sexo: {FFFFFF}%s\n{FF8040}Edad: {FFFFFF}%d\n{FF8040}Residencia: {FFFFFF}%s\n{FF8040}Trabajo: {FFFFFF}%s\n{FF8040}Cargo: {FFFFFF}%s\n{FF8040}Relación: {FFFFFF}%s", RemoveUnderScore(playerid), sexo, edad, ciudad, trabajo, cargo, relacion);
		ShowPlayerDialog(pID, DIALOG_PASAPORTE, DIALOG_STYLE_MSGBOX, "\t{C0C0C0}....::{0080FF}San {FF0000}Andreas {FF8000}Passport{C0C0C0}::....", string, "Aceptar","");
		SendClientMessageToAll(-1, string2);
	}
	else
	{
    format(string2, sizeof(string2), "{C2A2DA}* %s le enseña su pasaporte a %s", RemoveUnderScore(playerid), RemoveUnderScore(pID));
	format(string, sizeof(string), "{FF8040}Nombre: {FFFFFF}%s\n{FF8040}Sexo: {FFFFFF}%s\n{FF8040}Edad: {FFFFFF}%d\n{FF8040}Residencia: {FFFFFF}%s\n{FF8040}Trabajo: {FFFFFF}%s\n{FF8040}Cargo: {FFFFFF}%s\n{FF8040}Relación: {FFFFFF}%s", RemoveUnderScore(playerid), sexo, edad, ciudad, trabajo, cargo, relacion);
	ShowPlayerDialog(pID, DIALOG_PASAPORTE, DIALOG_STYLE_MSGBOX, "\t{C0C0C0}....::{0080FF}San {FF0000}Andreas {FF8000}Passport{C0C0C0}::....", string, "Aceptar","");
	SendClientMessageToAll(-1, string2);
	}
	return 1;
    }
	else
	{
	SendClientMessageEx(playerid, -1, "{A7A7A7}[Administración]: El jugador se encuentra muy lejos.");
	}
	return 1;
}
CMD:vc(playerid, params[])//COMANDO /VC
{
	if( PlayersData[playerid][Vip] >= 1 )
	{
	    if (isnull(params))
        {
            SendInfoMessage(playerid, 0, "0", "{A7A7A7}[Administración]: Utiliza /vc [Texto]");
            return 1;
		}
	    new VIPRank[64];
	    if(PlayersData[playerid][Vip] == 1) { VIPRank = "{E6C71A}VIP"; }
		else if(PlayersData[playerid][Vip] == 2) { VIPRank = "{FF8080}Admin{E6C71A}VIP"; }
	    if (strlen(params) > 125)
		{
	        SendClientMessageX(-1, "{FFFF80}[{FFFFFF}CHAT VIP{FFFF80}]: %s  {FFFFFF}%s{FFFF80}: %.64s", VIPRank, RemoveUnderScore(playerid), params);
	        SendClientMessageX(-1, "...%s", params[64]);
	    }
	    else
		{
	        SendClientMessageX(-1, "{FFFF80}[{FFFFFF}CHAT VIP{FFFF80}]: %s  {FFFFFF}%s{FFFF80}: %s", VIPRank, RemoveUnderScore(playerid), params);
		}
	}
	else
	{
	    SendInfoMessage(playerid, 0, "0", "{FF4D53}[Administración]: Debes ser miembro VIP para disfrutar de estas caracteristicas.");
	}
	return 1;
}
CMD:stats(playerid, params[])
{
	new string2[400], dinero, sexo[10], skin, nivel, Float:chaleco, nAdmin[35];
	dinero= GetPlayerMoney(playerid);
	if(PlayersData[playerid][Sexo] ==1){    sexo= "Femenino";}
	if(PlayersData[playerid][Sexo] ==2){    sexo= "Masculino";}
	skin= GetPlayerSkin(playerid);
	nivel= (PlayersData[playerid][Nivel]);
	GetPlayerArmour(playerid, chaleco);
 	if(PlayersData[playerid][Admin] == 0) { nAdmin = "{FFFFFF}Ninguno."; }
 	else if(PlayersData[playerid][Admin] == 1) { nAdmin = "{80FFFF}Ayudante"; }
	else if(PlayersData[playerid][Admin] == 2) { nAdmin = "{00FF00}Staff"; }
	else if(PlayersData[playerid][Admin] == 3) { nAdmin = "{0080FF}Moderador"; }
	else if(PlayersData[playerid][Admin] == 4) { nAdmin = "{800040}Coordinador"; }
	else if(PlayersData[playerid][Admin] == 5) { nAdmin = "{FF0000}Co-Admin"; }
	else if(PlayersData[playerid][Admin] == 6) { nAdmin = "{400000}Administrador"; }
	else if(PlayersData[playerid][Admin] == 7) { nAdmin = "{3C3C3C}Scripter"; }
	format(string2,sizeof(string2),"{0080FF}Nombre: {FFFFFF}%s\n{0080FF}Nivel: {FFFFFF}%d\n{0080FF}Dinero: {008000}${FFFFFF}%d\n{0080FF}Sexo: {FFFFFF}%s\n{0080FF}Skin: {FFFFFF}%d\n{0080FF}Chaleco: {FFFFFF}%d\n{0080FF}Administración: %s",RemoveUnderScore(playerid), nivel, dinero, sexo, skin, chaleco, nAdmin);
	ShowPlayerDialog(playerid,DIALOG_STATS,DIALOG_STYLE_MSGBOX,"{FF3535}Panel{FFFFFF}» {FF8000}Estadisticas",string2,"Cerrar","");
	return 1;
}
CMD:admins(playerid, params[])
{
	new ladm[150], rango[25], estado[25];
	for(new i=0; i<= 200; i++)
	{
		if (IsPlayerConnected(i) || PlayersData[i][Admin] >= 1)
		{
		if(PlayersData[i][Admin] == 1) { rango = "{80FFFF}Ayudante"; }
		else if(PlayersData[i][Admin] == 2) { rango = "{00FF00}Staff"; }
  		else if(PlayersData[i][Admin] == 3) { rango = "{0080FF}Moderador"; }
  		else if(PlayersData[i][Admin] == 4) { rango = "{800040}Coordinador"; }
		else if(PlayersData[i][Admin] == 5) { rango = "{FF0000}Co-Admin"; }
 		else if(PlayersData[i][Admin] == 6) { rango = "{400000}Administrador"; }
		else if(PlayersData[i][Admin] == 7) { rango = "{3C3C3C}Scripter";}
		if(PlayersData[i][AdminOn] == 0) { estado = "{FF53FF}Roleando";}
		else if(PlayersData[i][AdminOn] == 1) { estado = "{FF0000}Servicio";}
		SendClientMessage(playerid, -1, "{9B9B9B}.................................::::{B90000}Admin{008000} Online{9B9B9B}::::.................................");
		format(ladm, sizeof(ladm), "%s:{FFFFBB} %s {A7A7A7}[%s{A7A7A7}]", rango, RemoveUnderScore(i), estado);
		SendClientMessage(playerid, -1, ladm);
		}
	}
	return 1;
}
CMD:duda(playerid, params[])
{
	new msg[300];
	if (isnull(params))
	{
  		SendInfoMessage(playerid, 0, "0", "{A7A7A7}[Administración]: Utiliza /Duda [Texto]");
    	return 1;
	}
 	format(msg, sizeof(msg), "{FF8080}[Dudas]: {FF80C0}%s {A7A7A7}[ID: %d]: %s", RemoveUnderScore(playerid), playerid, params);
	if(PlayersData[playerid][Admin] >=1)
	{
	    SendClientMessage(playerid, -1, msg);
	}
	else
	{
	    SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Haz enviado una duda a la administración, espera que te respondan.");
	}
	return 1;
}
CMD:reportar(playerid, params[])
{
	new msg[300], pr;
	if(isnull(params))
	{
	    SendClientMessage(playerid,-1, "{A7A7A7}[Administración]: Utiliza /Reportar [ID] [Razón]");
	}
	if(PlayersData[playerid][Admin] >=1)
	{
	    pr= params[0];
 		format(msg, sizeof(msg), "{C60000}[Reportes]: El usuario %s[ID: %d] fue reportado por: %s", RemoveUnderScore(pr), pr, params[1]);
	    SendClientMessage(playerid, -1, msg);
	}
	else
	{
		format(msg, sizeof(msg), "{C60000}[Reportes]: Haz reportado a %s[ID: %d] por: %s", RemoveUnderScore(pr), pr, params[1]);
	    SendClientMessage(playerid, -1, msg);
	}
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
	    	SendClientMessage(playerid, -1, "{8E8E8E}/CmdStaff - /A [Canal Admin] - /O [Canal General] - /AdminOn - /Spec [ID]");
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
	    SendInfoMessage(playerid, 0, "0", "{FF4D53}[Administración]: No autorizado.");
	}
	return 1;
}
CMD:a(playerid, params[])
{
	if( PlayersData[playerid][Admin] >= 1 )
	{
	    if (isnull(params))
        {
            SendInfoMessage(playerid, 0, "0", "{A7A7A7}[Administración]: Utiliza /A [Texto]");
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
	    SendInfoMessage(playerid, 0, "0", "{FF4D53}[Administración]: No tienes acceso al chat administrativo, utiliza /w [ID].");
	}
	return 1;
}
CMD:traer(playerid,params[])
{
	if( PlayersData[playerid][Admin] >=2 )
	{
	    if (isnull(params))
        {
            SendInfoMessage(playerid, 0, "0", "{A7A7A7}[Administración]: Utiliza /Traer [ID]");
            return 1;
		}
    	new pID, Float:pX, Float:pY, Float:pZ, Mensaje[120];
    	pID = strval(params);
    	if(!IsPlayerConnected(pID)) return SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Jugador no conectado.");
    	GetPlayerPos(playerid, pX, pY, pZ);
    	SetPlayerPos(pID, pX+2, pY, pZ);
    	SetPlayerInterior(pID, GetPlayerInterior(playerid));
    	SetPlayerVirtualWorld(pID, GetPlayerVirtualWorld(playerid));
    	format(Mensaje, sizeof(Mensaje), "{A7A7A7}[Administración]: Has traído a tu posición a %s.", RemoveUnderScore(pID));
    	SendClientMessage(playerid, -1, Mensaje);
    	format(Mensaje, sizeof(Mensaje), "{A7A7A7}[Administración]: %s te ha llevado a su posición.", RemoveUnderScore(playerid));
    	SendClientMessage(pID, -1, Mensaje);
	 }
	 else SendClientMessage(playerid, -1, "{FF4D53}[Administración]: No tienes acceso a este comando.");
    return 1;
}
CMD:ir(playerid,params[])
{
	if( PlayersData[playerid][Admin] >=2 )
	{
	    if (isnull(params))
        {
            SendInfoMessage(playerid, 0, "0", "{A7A7A7}[Administración]: Utiliza /Ir [ID]");
            return 1;
		}
    	new pID, Float:pX, Float:pY, Float:pZ, Mensaje[120];
    	pID = strval(params);
    	if(!IsPlayerConnected(pID)) return SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: El jugador no se encuentra conectado.");
    	GetPlayerPos(pID, pX, pY, pZ);
    	SetPlayerPos(playerid, pX+2, pY, pZ);
    	SetPlayerInterior(playerid, GetPlayerInterior(pID));
    	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(pID));
    	format(Mensaje, sizeof(Mensaje), "{A7A7A7}[Administración]: Has ido a la posición de %s.", RemoveUnderScore(pID));
    	SendClientMessage(playerid, -1, Mensaje);
    	format(Mensaje, sizeof(Mensaje), "{A7A7A7}[Administración]: %s se a teletransportado a tu posición", RemoveUnderScore(playerid));
    	SendClientMessage(pID, -1, Mensaje);
	 }
	 else SendClientMessage(playerid, -1, "{FF4D53}[Administración]: No tienes acceso a este comando.");
    return 1;
}
CMD:reiniciarservidor(playerid, params[])
{
    new str[226];
    if(PlayersData[playerid][Admin] >= 6)
    {
    format(str, sizeof(str), "{A7A7A7}[Administración]: El servidor se reiniciará en 1 minuto. By: %s.", RemoveUnderScore(playerid));
    SendClientMessageToAll(-1, str);
	GameTextForAll( "~W~El servidor se reiniciara~N~ ~R~1 minuto", 3000, 0);
    SetTimer("Reiniciar", 60000, false);
    YSI_Save_Account(playerid);
    }
    else
	{
	    SendInfoMessage(playerid, 0, "0", "{FF4D53}[Administración]: No tienes acceso a este comando.");
     	SetTimerEx("KickPlayer",200,false,"i",playerid);
	}
    return 1;
}
CMD:forzarreinicio(playerid, params[])
{
    new str[226];
    if(PlayersData[playerid][Admin] >= 6)
    {
    format(str, sizeof(str), "{A7A7A7}[Administración]: Se forzó el reinicio. By: %s.", RemoveUnderScore(playerid));
	GameTextForAll( "~R~Reiniciando Servidor", 6000, 0);
    SendClientMessageToAll(-1, str);
    SetTimer("Reiniciar", 100, false);
    YSI_Save_Account(playerid);
    }
    else
	{
	    SendInfoMessage(playerid, 0, "0", "{FF4D53}[Administración]: No tienes acceso a este comando.");
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
            SendInfoMessage(playerid, 0, "0", "{A7A7A7}[Administración]: Utiliza /Servidor [Texto]");
            return 1;
		}
		format(string, sizeof(string), "{FF0000}*{0080FF}Servidor: %s", params);
		SendClientMessageToAll(-1,string);
	}
	else
	{
	SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: No tiene acceso a este comando.");
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
            SendInfoMessage(playerid, 0, "0", "{A7A7A7}[Administración]: Utiliza /O [Texto General]");
            return 1;
		}
    	format(str, sizeof(str), "{FFA214}[OOC] %s: %s", RemoveUnderScore(playerid), params);
    	SendClientMessageToAll(-1, str);
    }
    else
	{
	    SendInfoMessage(playerid, 0, "0", "{FF4D53}[Administración]: No tienes acceso a este comando.");
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
    format(string, sizeof(string), "{A7A7A7}[Administración]: El administrador %s [ID: %d] te ha dado {20A704}$%d{A7A7A7} dólares.", RemoveUnderScore(playerid), playerid, params[1]);
    SendClientMessage(params[0], -1, string);

    new string2[180];
    format(string2, sizeof(string2), "{A7A7A7}[Administración]: Le diste {20A704}$%d{A7A7A7} dolares a %s [ID: %d]", params[1], RemoveUnderScore(params[0]), params[0]);
    SendClientMessage(playerid, -1, string2);
  }
  else SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: El jugador no esta conectado.");
}
else SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Utiliza /DarDinero [ID] [Monto]");
}
else SendClientMessage(playerid, -1, "{FF4D53}[Administración]: No tienes acceso a este comando.");// Mensaje de la variable admin.
return 1;
}
CMD:test(playerid, params[])
{
if(PlayersData[playerid][Admin] >= 2)
{
	new id, string[126], Float: PPos[3];
	if(sscanf(params, "u", id))
		return SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Utiliza /Test [ID]");
	GetPlayerPos(id, PPos[0], PPos[1], PPos[2]);
	SetPlayerPos(id, PPos[0], PPos[1], PPos[2]+5);
	format(string, sizeof(string), "{A7A7A7}[Administración]: Haz desbuggeado al usuario %s.", RemoveUnderScore(id));
	SendClientMessage(playerid, -1, string);
}
else SendClientMessage(playerid, -1, "{FF4D53}[Administración]: No tienes acceso a este comando.");
return 1;
}
CMD:vida(playerid, params[])
{
if(PlayersData[playerid][Admin] >=4)
{
	new id, string[126];
	if(sscanf(params, "u", id))
	 	return SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Utiliza /Vida [ID]");
	SetPlayerHealth(id, 100);
	format(string, sizeof(string), "{A7A7A7}[Administración]: Le haz dado vida a %s .", RemoveUnderScore(id));
 	SendClientMessage(playerid, -1, string);
}
else SendClientMessage(playerid, -1, "{FF4D53}[Administración]: No tienes acceso a este comando.");
return 1;
}
CMD:congelar(playerid, params[])
{
if(PlayersData[playerid][Admin] >=2)
{
	new id, string[126];
	if(sscanf(params, "u", id))
	    return SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Utiliza /Congelar [ID]");
    TogglePlayerControllable(id, 0);
    format(string, sizeof(string), "{A7A7A7}[Administración]: %s te ha congelado.", RemoveUnderScore(playerid));
    SendClientMessage(id,-1, string);
}
else SendClientMessage(playerid, -1, "{FF5D53}[Administración]: No tienes acceso a este comando.");
return 1;
}
CMD:descongelar(playerid, params[])
{
if(PlayersData[playerid][Admin] >=2)
{
	new id, string[126];
	if(sscanf(params, "u", id))
	    return SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Utiliza /Descongelar [ID]");
    TogglePlayerControllable(id, 1);
    format(string, sizeof(string), "{A7A7A7}[Administración]: %s te ha descongelado.", RemoveUnderScore(playerid));
    SendClientMessage(id,-1, string);
}
else SendClientMessage(playerid, -1, "{FF5D53}[Administración]: No tienes acceso a este comando.");
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
    format(string, sizeof(string), "{A7A7A7}[Administración]: El administrador %s [ID: %d] te ha asignado el rango %s de administrador.", RemoveUnderScore(playerid), playerid, rango);
    SendClientMessage(params[0], -1, string);
    new string2[180];
    format(string2, sizeof(string2), "{A7A7A7}[Administración]: Le diste el rango administrativo %s a %s [id: %d]", rango, RemoveUnderScore(params[0]), params[0]);
    SendClientMessage(playerid, -1, string2);
  }
  else SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: El jugador no esta conectado.");
}
else SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Utiliza /Staff [ID] [Rango]");
}
else SendClientMessage(playerid, -1, "{FF4D53}[Administración]: No tienes acceso a este comando.");
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
    format(string, sizeof(string), "{A7A7A7}[Administración]: El administrador %s [ID: %d] te kickeó del servidor.", RemoveUnderScore(playerid), playerid);
    SendClientMessage(params[0], -1, string);
    new string2[180];
    format(string2, sizeof(string2), "{A7A7A7}[Administración]: Haz kickeado a %s", RemoveUnderScore(params[0]));
    SendClientMessage(playerid, -1, string2);
    SetTimerEx("KickPlayer",400,false,"i",params[0]);
  }
  else SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: El jugador no esta conectado.");
}
else SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Utiliza /Kick [ID]");
}
else SendClientMessage(playerid, -1, "{FF4D53}[Administración]: No tienes acceso a este comando.");
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
    format(string, sizeof(string), "{A7A7A7}[Administración]: El administrador %s te ha baneado del Servidor. {0080FF}Razón: %s.", RemoveUnderScore(playerid), params[1]);
    SendClientMessage(params[0], -1, string);
    new string2[180];
    format(string2, sizeof(string2), "{A7A7A7}[Administración]: Haz baneado al usuario %s", RemoveUnderScore(params[0]));
    SendClientMessage(playerid, -1, string2);
    SendClientMessage(params[0], -1, "{A7A7A7}[Administración]: {FFFF00}Se te recomienda tomar una Screenshot de este momento, así será válida tu apelación. Gracias por jugar!.");
    PlayersData[(params[0])][Baneado] = 1;
    SetTimerEx("BanPlayer",300,false,"i",params[0]);
  }
  else SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: El jugador no esta conectado.");
}
else SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Utiliza /Ban [ID] [Razón]");
}
else SendClientMessage(playerid, -1, "{FF4D53}[Administración]: No tienes acceso a este comando.");
return 1;
}
forward BanPlayer(playerid);
public BanPlayer(playerid)
{
Ban(playerid);
return 1;
}
CMD:adminon(playerid, params[])
{
	new Float: PPos[3], skin, Float:vida;
	skin=(PlayersData[playerid][Skin]);
	GetPlayerHealth(playerid, vida);
	if(PlayersData[playerid][Admin] >=1)
	{
	    if(PlayersData[playerid][AdminOn]==0)
	    {
	        PlayersData[playerid][AdminOn] = 1;
	        SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Ahora estás OnDuty.");
	        SetPlayerHealth(playerid, 496700);
			SetPlayerSkin(playerid, 0);
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
			SetPlayerSkin(playerid, skin);
			SetPlayerHealth(playerid, vida);
			GetPlayerPos(playerid, PPos[0], PPos[1], PPos[2]);
			SetPlayerPos(playerid, PPos[0], PPos[1], PPos[2]+2);
			SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Ya no estás OnDuty.");
		}
	}
	else
	{
	SendClientMessage(playerid, -1, "{FF4D53}[Administración]: No tienes acceso a este comando.");
	}
	return 1;
}
CMD:clima(playerid,params[])
{
	if( PlayersData[playerid][Admin] >=5 )
	{
	    if (isnull(params))
        {
            SendInfoMessage(playerid, 0, "0", "{A7A7A7}[Administración]: Utiliza /Clima [Valor]");
            return 1;
		}
    	new cID, Mensaje[120];
    	cID= strval(params);
    	SetWeather(cID);
    	format(Mensaje, sizeof(Mensaje), "{A7A7A7}[Administración]: Haz cambiado el clima al ID: %d", cID);
    	SendClientMessage(playerid, -1, Mensaje);
	 }
	 else SendClientMessage(playerid, -1, "{FF4D53}[Administración]: No tienes acceso a este comando.");
    return 1;
}
CMD:ircoord(playerid, params[])
{
	if(PlayersData[playerid][Admin] >=4)
	{
	    if(isnull(params))
	    {
	        SendInfoMessage(playerid, 0, "0", "{A7A7A7}[Administración]: Utiliza /IrCoord [x] [y] [z]");
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
	    return SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Utiliza /SetSkin [ID]");
 	sk=strval(params);
  	SetPlayerSkin(playerid, sk);
  	PlayersData[playerid][Skin] = sk;
    format(string, sizeof(string), "{A7A7A7}[Administración]: Haz cambiado tu skin al ID: %d", sk);
    SendClientMessage(playerid,-1, string);
}
else SendClientMessage(playerid, -1, "{FF5D53}[Administración]: No tienes acceso a este comando.");
return 1;
}
CMD:weapon(playerid, params[])
{
if(PlayersData[playerid][Admin] >=5)
{
	new a, string[126];
	if(sscanf(params, "u", a))
	    return SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Utiliza /weapon [ID_Arma]");
 	a=strval(params);
  	GivePlayerWeapon(playerid, a, 30);
    format(string, sizeof(string), "{A7A7A7}[Administración]: Se te ha dado el arma ID: %d con 30 balas.", a);
    SendClientMessage(playerid,-1, string);
}
else SendClientMessage(playerid, -1, "{FF5D53}[Administración]: No tienes acceso a este comando.");
return 1;
}
CMD:dovip(playerid, params[])
{
if(PlayersData[playerid][Admin] >=6)
{
	new id, string[126], anuncio[500];
	if(sscanf(params, "u", id))
	 	return SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Utiliza /dovip [ID]");
	PlayersData[id][Vip] = 1;
	SetPlayerColor(id, 0xF1D50EFF);
	GivePlayerMoney(id, 5000);
	format(string, sizeof(string), "{A7A7A7}[Administración]: Haz otorgado una suscripcion VIP a %s.", RemoveUnderScore(id));
 	SendClientMessage(playerid, -1, string);
 	format(string, sizeof(string), "{FFFF00}[Información]: El administador %s te ha otorgado una suscripción VIP!", RemoveUnderScore(playerid));
	SendClientMessage(id, -1, string);
	format(anuncio,sizeof(anuncio),"{FF3E3E}Felicidades {FFFFFF}%s{FF3E3E}!\n\n{A8FFFF}Acabas de obtener tu Membresía {E6C71A}VIP{A8FFFF}!\n{A8FFFF}Esperamos que la disfrutes! Ahora puedes usar el {E6C71A}Chat VIP{A7A7A7}({FF00FF}/vc [texto]{A7A7A7})\n{FF2424}*Recuerda que la Administración puede Leer el Chat\n{FF2424}Cualquier rastro de MG será fuertemente sancionado.\n\n{0080FF}Más beneficios, vía foro!",RemoveUnderScore(id));
	ShowPlayerDialog(id,DIALOG_VIP,DIALOG_STYLE_MSGBOX,"{FF8000}Suscripción {FFFFFF}» {E6C71A}VIP",anuncio,"Aceptar","");
}
else SendClientMessage(playerid, -1, "{FF4D53}[Administración]: No tienes acceso a este comando.");
return 1;
}
CMD:removevip(playerid, params[])
{
if(PlayersData[playerid][Admin] >=6)
{
	new id, string[126];
	if(sscanf(params, "u", id))
	 	return SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Utiliza /removevip [ID]");
	PlayersData[id][Vip] = 0;
	SetPlayerColor(id, 0xFFFFFFFF);
	format(string, sizeof(string), "{A7A7A7}[Administración]: Le haz removido la suscripción VIP a %s.", RemoveUnderScore(id));
 	SendClientMessage(playerid, -1, string);
 	format(string, sizeof(string), "{FFFF00}[Información]: El administador %s te quitó tu suscripción VIP!", RemoveUnderScore(playerid));
	SendClientMessage(id, -1, string);
}
else SendClientMessage(playerid, -1, "{FF4D53}[Administración]: No tienes acceso a este comando.");
return 1;
}
CMD:clearchat(playerid, params[])
{
    if(PlayersData[playerid][Admin] >= 4)
    {
        for(new loop=0; loop<99; loop++)  SendClientMessageToAll(COLOR_BLANCO," ");
        SendClientMessageToAll(COLOR_BLANCO,"{0080FF}El chat ha sido limpiado!");
        }
    else
    {
        SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: No tienes acceso a este comando.");
    }
    return 1;
}
CMD:spamear(playerid, params[])
{
	if(PlayersData[playerid][Admin] >=4)
	{
	    new msg[150];
 	    format(msg, sizeof(msg), "{C9C9C9}Anuncio creado por: {A7A7A7}%s.", RemoveUnderScore(playerid));
	    SendClientMessageToAll(COLOR_BLANCO, msg);
	    for(new loop=0; loop<11; loop++)
	    {
	    format(msg, sizeof(msg),  "{0080FF}[{FF0000}Spam{0080FF}]: {80FF00}%s.", params);
	    SendClientMessageToAll(COLOR_BLANCO,msg);
	    }
	    format(msg, sizeof(msg), "{C9C9C9}Anuncio creado por: {A7A7A7}%s.", RemoveUnderScore(playerid));
	    SendClientMessageToAll(COLOR_BLANCO, msg);
	}
	else
	{
	    SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: No tienes acceso a este comando.");
	}
	return 1;
}
CMD:warn(playerid, params[])
{
	if(PlayersData[playerid][Admin] >=4)
	{
		new id, string[126];
		if(sscanf(params, "u", id))
	 		return SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Utiliza /Warn [ID]");
		PlayersData[id][Warn]++;
		format(string, sizeof(string), "{A7A7A7}[Administración]: Le haz dado un Warn al usuario %s [ID: %d].", RemoveUnderScore(playerid), playerid);
		SendClientMessage(playerid, -1, string);
		format(string, sizeof(string), "{A7A7A7}[Administración]: El Administrador %s [ID: %d] te ha dado un warn!", RemoveUnderScore(playerid), id);
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
	        return SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Utiliza /Spawn [ID]");
		SetPlayerPos(id, -2050.9604,462.0917,35.1719);
		format(msg,sizeof(msg), "{A7A7A7}[Administración]: El administrador %s te ha Spawneado.", RemoveUnderScore(playerid));
		SendClientMessage(id, -1, msg);
		format(msg, sizeof(msg), "{A7A7A7}[Administración]: Haz Spawneado al usuario %s", RemoveUnderScore(id));
		SendClientMessage(playerid, -1, msg);
	}
	else
	{
		SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: No tienes acceso a este comando.");
	}
	return 1;
}
CMD:mohamed(playerid,params[])
{
	if(PlayersData[playerid][Admin] >= 6)
	{
		new id, msg[100];
		if(sscanf(params,"d",id))return SendClientMessage(playerid,-1,"{A7A7A7}[Administración]: Utiliza /Mohamed [ID]");
		if(IsPlayerConnected(id))
		{
			new Float:x,Float:y,Float:z;
			GetPlayerPos(id,x,y,z);
			CreateExplosion(x, y, z, 7, 20.0);
			SetPlayerPos(id, x, y, z+5);
			format(msg, sizeof(msg), "{A7A7A7}[Administración]: Haz detonado a %s", RemoveUnderScore(id));
			SendClientMessage(playerid, -1, msg);
		}
	}
	else
	{
		SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: No tienes acceso a este comando.");
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
            if(sscanf(params,"d",id))return SendClientMessage(playerid,-1,"{A7A7A7}[Administración]: Utiliza /Spec [ID]");
            if(IsPlayerConnected(id))
            {
                Spectador[playerid] = true;
                PlayerSpectatePlayer(playerid, id,SPECTATE_MODE_FIXED);
                TogglePlayerSpectating(playerid, 1);
                format(msg, sizeof(msg), "{A7A7A7}[Administración]: Estás especteando a %s.", RemoveUnderScore(id));
                SendClientMessage(playerid,-1, msg);
            }

        }
        else
        {
            new msg2[100], id;
            Spectador[playerid] = false;
            TogglePlayerSpectating(playerid, 0);
            SetCameraBehindPlayer(playerid);
            format(msg2, sizeof(msg2), "{A7A7A7}[Administración]: Haz dejado de Espectear a %s.", RemoveUnderScore(id));
            SendClientMessage(playerid,-1, msg2);
        }
    }
    else
	{
	    SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: No tienes acceso a este comando.");
	}
    return 1;
}
CMD:testping(playerid,params[])
{
	if(PlayersData[playerid][Admin]==7)
	{
	    new string[120], a;
	    a=1;
	    format(string, sizeof(string), "{A7A7A7}[Administración]: {0080FF}El administrador {FFFFFF}%s{0080FF} ha realizado un LaggTest", RemoveUnderScore(playerid));
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
	    SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: No tienes acceso a este comando.");
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
	    		SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: El usuario no se encuentra conectado.");
			}
	}
   	else
    {
        SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: No tienes acceso a este comando.");
	}
	return 1;
}
CMD:msgex(playerid, params[])
{
	if(PlayersData[playerid][Admin] >=6)
	{
	    GameTextForPlayer(playerid, params,3000,3);
 	}
 	else
 	{
 	    SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: No tienes acceso a este comando.");
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
	    	format(msg, sizeof(msg), "{A7A7A7}[Administración]: Bienvenido de nuevo {FFFFFF}%s{A7A7A7} a la {FF0000}Zona{0080FF}Staff{A7A7A7}.", RemoveUnderScore(playerid));
	    	SendClientMessage(playerid, -1, msg);
		}
		else
		{
	    	SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: Debes estár OnDuty para usar este comando.");
		}
	}
	else
	{
	    SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: No tienes acceso a este comando.");
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
		format(msg, sizeof(msg), "{A7A7A7}[Administración]: Haz matado a %s", RemoveUnderScore(pID));
		SendClientMessage(playerid, -1, msg);
		format(msg, sizeof(msg), "{A7A7A7}[Administración]: El administrador %s te ha matado.", RemoveUnderScore(playerid));
		SendClientMessage(pID, -1, msg);
	}
	else
	{
		SendClientMessage(playerid, -1, "{A7A7A7}[Administración]: No tienes acceso a este comando.");
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
