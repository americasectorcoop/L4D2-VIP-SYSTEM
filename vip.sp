#pragma semicolon 1
#include <sourcemod>
#include <sdktools_functions>
#include <colors>
// Using the latest sourcemod api
#pragma newdecls required
// Types
#define WEAPON_TIME 0
#define WEAPON_NAME 1
#define WEAPON_LEVEL 2
#define WEAPON_TYPE 3
#define WEAPON_SLOT 4
// Levels
#define VIP_SILVER "0"
#define VIP_GOLD "1"
#define VIP_PREMIUM "2"
// Weapons Types
#define TYPE_WEAPON "0"
#define TYPE_MELEE "1"
#define TYPE_MISC "2"
// Number of weapons
#define PRINCIPAL "0"
#define SECONDARY "1"
#define GRENADES "2"
#define PACKS "3"
#define ITEMS "4"
#define UPGRADE "5"
// Defining if we will use sqlite
#define USE_DB true //<-false was in false
// Number of weapons
#define NUMBER_WEAPONS 28
// weapons_list[number_of_weapons][types][sizeof_value]
char weapons_list[NUMBER_WEAPONS][5][32]; 
// Array to save the color of the aura
int player_aura[MAXPLAYERS+1] = {0, ...};
// Variable for count times where player use vip in the map
int counters[3][MAXPLAYERS+1];
#define USE_VIP 0
#define USE_DROP 1
#define QUOTA 2
// Checking if database is used
#if USE_DB
// Database to use
#define DB_CONF_NAME "storage-local"
// Initializing database
Database g_dbConnection = null; 
// If not
#else
// Initializing variable for the timers
int weapon_timers[MAXPLAYERS + 1][NUMBER_WEAPONS];
// Finishing block
#endif

/**
 * Definiendo informacion del plugin
 */
public Plugin myinfo = {
  name = "VIP System for ASC",
  author = "Aleexxx",
  description = "VIP system for ASC, weapons, melees, etc using SQLite",
  version = "1.0.6",
  url = "http://draen.org"
}


bool g_bPoints = false;

native int TYSTATS_GetPoints(int client);

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
  MarkNativeAsOptional("TYSTATS_GetPoints");
  return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
  g_bPoints = GetFeatureStatus(FeatureType_Native, "TYSTATS_GetPoints") == FeatureStatus_Available;
}


/**
 * Acciones al iniciar el plugin
 */
public void OnPluginStart() {

  LoadTranslations("common.phrases");
  
  #if USE_DB
  InitDB();
  #endif

  weapons_list[0][WEAPON_TIME] = "1080";
  weapons_list[0][WEAPON_NAME] = "tonfa"; 
  weapons_list[0][WEAPON_LEVEL] = VIP_SILVER;
  weapons_list[0][WEAPON_TYPE] = TYPE_MELEE;
  weapons_list[0][WEAPON_SLOT] = SECONDARY;
  weapons_list[1][WEAPON_TIME] = "1080";
  weapons_list[1][WEAPON_NAME] = "frying_pan";
  weapons_list[1][WEAPON_LEVEL] = VIP_SILVER;
  weapons_list[1][WEAPON_TYPE] = TYPE_MELEE;
  weapons_list[1][WEAPON_SLOT] = SECONDARY;
  weapons_list[2][WEAPON_TIME] = "1080";
  weapons_list[2][WEAPON_NAME] = "crowbar";
  weapons_list[2][WEAPON_LEVEL] = VIP_SILVER;
  weapons_list[2][WEAPON_TYPE] =TYPE_MELEE;
  weapons_list[2][WEAPON_SLOT] = SECONDARY;
  weapons_list[3][WEAPON_TIME] = "1080";
  weapons_list[3][WEAPON_NAME] = "golfclub";
  weapons_list[3][WEAPON_LEVEL] = VIP_SILVER;
  weapons_list[3][WEAPON_TYPE] = TYPE_MELEE;
  weapons_list[3][WEAPON_SLOT] = SECONDARY;
  weapons_list[4][WEAPON_TIME] = "1080";
  weapons_list[4][WEAPON_NAME] = "cricket_bat";
  weapons_list[4][WEAPON_LEVEL] = VIP_GOLD;
  weapons_list[4][WEAPON_TYPE] = TYPE_MELEE;
  weapons_list[4][WEAPON_SLOT] = SECONDARY;
  weapons_list[5][WEAPON_TIME] = "1080";
  weapons_list[5][WEAPON_NAME] = "electric_guitar";
  weapons_list[5][WEAPON_LEVEL] = VIP_GOLD;
  weapons_list[5][WEAPON_TYPE] = TYPE_MELEE;
  weapons_list[5][WEAPON_SLOT] = SECONDARY;
  weapons_list[6][WEAPON_TIME] = "1080";
  weapons_list[6][WEAPON_NAME] = "baseball_bat";
  weapons_list[6][WEAPON_LEVEL] = VIP_GOLD;
  weapons_list[6][WEAPON_TYPE] = TYPE_MELEE;
  weapons_list[6][WEAPON_SLOT] = SECONDARY;
  weapons_list[7][WEAPON_TIME] = "1080";
  weapons_list[7][WEAPON_NAME] = "fireaxe";
  weapons_list[7][WEAPON_LEVEL] = VIP_GOLD;
  weapons_list[7][WEAPON_TYPE] = TYPE_MELEE;
  weapons_list[7][WEAPON_SLOT] = SECONDARY;
  weapons_list[8][WEAPON_TIME] = "1080";
  weapons_list[8][WEAPON_NAME] = "machete";
  weapons_list[8][WEAPON_LEVEL] = VIP_PREMIUM;
  weapons_list[8][WEAPON_TYPE] = TYPE_MELEE;
  weapons_list[8][WEAPON_SLOT] = SECONDARY;
  weapons_list[9][WEAPON_TIME] = "1080";
  weapons_list[9][WEAPON_NAME] = "knife";
  weapons_list[9][WEAPON_LEVEL] = VIP_PREMIUM;
  weapons_list[9][WEAPON_TYPE] = TYPE_MELEE;
  weapons_list[9][WEAPON_SLOT] = SECONDARY;
  weapons_list[10][WEAPON_TIME] = "1080";
  weapons_list[10][WEAPON_NAME] = "katana";
  weapons_list[10][WEAPON_LEVEL] = VIP_PREMIUM;
  weapons_list[10][WEAPON_TYPE] = TYPE_MELEE;
  weapons_list[10][WEAPON_SLOT] = SECONDARY;
  weapons_list[11][WEAPON_TIME] = "900";
  weapons_list[11][WEAPON_NAME] = "smg_mp5";
  weapons_list[11][WEAPON_LEVEL] = VIP_SILVER;
  weapons_list[11][WEAPON_TYPE] = TYPE_WEAPON;
  weapons_list[11][WEAPON_SLOT] = PRINCIPAL;
  weapons_list[12][WEAPON_TIME] = "900";
  weapons_list[12][WEAPON_NAME] = "rifle_m60";
  weapons_list[12][WEAPON_LEVEL] = VIP_SILVER;
  weapons_list[12][WEAPON_TYPE] = TYPE_WEAPON;
  weapons_list[12][WEAPON_SLOT] = PRINCIPAL;
  weapons_list[13][WEAPON_TIME] = "900";
  weapons_list[13][WEAPON_NAME] = "rifle_sg552";
  weapons_list[13][WEAPON_LEVEL] = VIP_GOLD;
  weapons_list[13][WEAPON_TYPE] = TYPE_WEAPON;
  weapons_list[13][WEAPON_SLOT] = PRINCIPAL;
  weapons_list[14][WEAPON_TIME] = "1320";
  weapons_list[14][WEAPON_NAME] = "rifle_ak47";
  weapons_list[14][WEAPON_LEVEL] = VIP_GOLD;
  weapons_list[14][WEAPON_TYPE] = TYPE_WEAPON;
  weapons_list[14][WEAPON_SLOT] = PRINCIPAL;
  weapons_list[15][WEAPON_TIME] = "1320";
  weapons_list[15][WEAPON_NAME] = "shotgun_spas";
  weapons_list[15][WEAPON_LEVEL] = VIP_PREMIUM;
  weapons_list[15][WEAPON_TYPE] = TYPE_WEAPON;
  weapons_list[15][WEAPON_SLOT] = PRINCIPAL;
  weapons_list[16][WEAPON_TIME] = "1320";
  weapons_list[16][WEAPON_NAME] = "sniper_scout";
  weapons_list[16][WEAPON_LEVEL] = VIP_PREMIUM;
  weapons_list[16][WEAPON_TYPE] = TYPE_WEAPON;
  weapons_list[16][WEAPON_SLOT] = PRINCIPAL;
  weapons_list[17][WEAPON_TIME] = "1800";
  weapons_list[17][WEAPON_NAME] = "sniper_awp";
  weapons_list[17][WEAPON_LEVEL] = VIP_PREMIUM;
  weapons_list[17][WEAPON_TYPE] = TYPE_WEAPON;
  weapons_list[17][WEAPON_SLOT] = PRINCIPAL;
  weapons_list[18][WEAPON_TIME] = "900";
  weapons_list[18][WEAPON_NAME] = "molotov";
  weapons_list[18][WEAPON_LEVEL] = VIP_PREMIUM;
  weapons_list[18][WEAPON_TYPE] = TYPE_MISC;
  weapons_list[18][WEAPON_SLOT] = GRENADES;
  weapons_list[19][WEAPON_TIME] = "900";
  weapons_list[19][WEAPON_NAME] = "pipe_bomb";
  weapons_list[19][WEAPON_LEVEL] = VIP_SILVER;
  weapons_list[19][WEAPON_TYPE] = TYPE_MISC;
  weapons_list[19][WEAPON_SLOT] = GRENADES;
  weapons_list[20][WEAPON_TIME] = "900";
  weapons_list[20][WEAPON_NAME] = "vomitjar";
  weapons_list[20][WEAPON_LEVEL] = VIP_GOLD;
  weapons_list[20][WEAPON_TYPE] = TYPE_MISC;
  weapons_list[20][WEAPON_SLOT] = GRENADES;
  weapons_list[21][WEAPON_TIME] = "600";
  weapons_list[21][WEAPON_NAME] = "defibrillator";
  weapons_list[21][WEAPON_LEVEL] = VIP_GOLD;
  weapons_list[21][WEAPON_TYPE] = TYPE_MISC;
  weapons_list[21][WEAPON_SLOT] = ITEMS;
  weapons_list[22][WEAPON_TIME] = "900";
  weapons_list[22][WEAPON_NAME] = "first_aid_kit";
  weapons_list[22][WEAPON_LEVEL] = VIP_PREMIUM;
  weapons_list[22][WEAPON_TYPE] = TYPE_MISC;
  weapons_list[22][WEAPON_SLOT] = ITEMS;
  weapons_list[23][WEAPON_TIME] = "600";
  weapons_list[23][WEAPON_NAME] = "pain_pills";
  weapons_list[23][WEAPON_LEVEL] = VIP_PREMIUM;
  weapons_list[23][WEAPON_TYPE] = TYPE_MISC;
  weapons_list[23][WEAPON_SLOT] = ITEMS;
  weapons_list[24][WEAPON_TIME] = "1200";
  weapons_list[24][WEAPON_NAME] = "upgradepack_explosive";
  weapons_list[24][WEAPON_LEVEL] = VIP_PREMIUM;
  weapons_list[24][WEAPON_TYPE] = TYPE_MISC;
  weapons_list[24][WEAPON_SLOT] = PACKS;
  weapons_list[25][WEAPON_TIME] = "1200";
  weapons_list[25][WEAPON_NAME] = "upgradepack_incendiary";
  weapons_list[25][WEAPON_LEVEL] = VIP_GOLD;
  weapons_list[25][WEAPON_TYPE] = TYPE_MISC;
  weapons_list[25][WEAPON_SLOT] = PACKS;
  weapons_list[26][WEAPON_TIME] = "420";
  weapons_list[26][WEAPON_NAME] = "laser_sight";
  weapons_list[26][WEAPON_LEVEL] = VIP_SILVER;
  weapons_list[26][WEAPON_TYPE] = TYPE_MISC;
  weapons_list[26][WEAPON_SLOT] = UPGRADE;
  weapons_list[27][WEAPON_TIME] = "600";
  weapons_list[27][WEAPON_NAME] = "adrenaline";
  weapons_list[27][WEAPON_LEVEL] = VIP_PREMIUM;
  weapons_list[27][WEAPON_TYPE] = TYPE_MISC;
  weapons_list[27][WEAPON_SLOT] = ITEMS;

  // Commands
  RegConsoleCmd("sm_vip", Command_VIP);
  RegConsoleCmd("sm_aura", Command_Aura);
  RegConsoleCmd("sm_drop", Command_drop);
  RegAdminCmd("setaura", Commant_SetAura, ADMFLAG_ROOT);
  RegConsoleCmd("sm_buy", Command_Buy);
  RegConsoleCmd("sm_laser", Command_Laser);
  HookEvent("player_disconnect", Event_Disconnect, EventHookMode_Pre);
}

#if USE_DB
/** Connection to the database **/
public void InitDB() {
  // Verificando si existe nombre de configuracion
  // Checking if configuration name exists
  if (SQL_CheckConfig(DB_CONF_NAME)) {
    // Inicializando variable de error
    // Initialize error variable
    char Error[80];
    // Instanciando conexion sobre g_dbConnection
    // Instantiating connection over g_dbConnection
    g_dbConnection = SQL_Connect(DB_CONF_NAME, true, Error, sizeof(Error));
    // Verificando que g_dbConnection no sea igual a null
    // Verifying that g_dbConnection is not equal to null
    if (g_dbConnection == null) {
      // Registrando error en el log de errores
      // Logging error in error log
      LogError("Failed to connect to database: %s", Error);
      // Definiendo plugin como fail state(detiene el plugin)
      // Defining plugin as fail state (stops plugin)
      SetFailState("Failed to connect to database: %s", Error);
    } else {
      // Bloqueando conexion para verificar si existe la tabla
      // Blocking connection to check if table exists
      SQL_LockDatabase(g_dbConnection);
      // Verificando si existe la tabla de vip, en caso contrario crea la estructura
      // Checking if there exists the table of vip, otherwise creates the structure
      // En caso de que la consulta no se realice correctamente se correra el bloque
      // In case the query is not done correctly the block of code will run
      if(!SQL_FastQuery(g_dbConnection, "CREATE TABLE IF NOT EXISTS vip ( steamid TEXT UNIQUE, tonfa INTEGER DEFAULT 0, frying_pan INTEGER DEFAULT 0, crowbar INTEGER DEFAULT 0, golfclub INTEGER DEFAULT 0, cricket_bat INTEGER DEFAULT 0, electric_guitar INTEGER DEFAULT 0, baseball_bat INTEGER DEFAULT 0, fireaxe INTEGER DEFAULT 0, machete INTEGER DEFAULT 0, knife INTEGER DEFAULT 0, katana INTEGER DEFAULT 0, smg_mp5 INTEGER DEFAULT 0, rifle_m60 INTEGER DEFAULT 0, rifle_sg552 INTEGER DEFAULT 0, rifle_ak47 INTEGER DEFAULT 0, shotgun_spas INTEGER DEFAULT 0, sniper_scout INTEGER DEFAULT 0, sniper_awp INTEGER DEFAULT 0, molotov INTEGER DEFAULT 0, pipe_bomb INTEGER DEFAULT 0, vomitjar INTEGER DEFAULT 0, defibrillator INTEGER DEFAULT 0, first_aid_kit INTEGER DEFAULT 0, pain_pills INTEGER DEFAULT 0, upgradepack_explosive INTEGER DEFAULT 0, upgradepack_incendiary INTEGER DEFAULT 0, laser_sight INTEGER DEFAULT 0, adrenaline INTEGER DEFAULT 0 );")) {
        // Obteniendo error de la ocnsulta
        SQL_GetError(g_dbConnection, Error, sizeof(Error));
        // Guardando error en el log de errores
        LogError("SQL Error: %s", Error);
        // Definiendo el estado del plugin como fail state (detiene el plugin)
        SetFailState("SQL Error: %s", Error);
      } else if(!SQL_FastQuery(g_dbConnection, "DELETE FROM vip;")) {
        // Obteniendo error de la ocnsulta
        SQL_GetError(g_dbConnection, Error, sizeof(Error));
        // Guardando error en el log de errores
        LogError("SQL Error: %s", Error);
      }
      // Desbloqueando database
      // Unlocking database
      SQL_UnlockDatabase(g_dbConnection);
    }
  } else {
    // Guardando error en el log de errores
    // Saving error in the error log
    LogError("database.cfg missing '%s' entry!", DB_CONF_NAME);
    // Definiendo fail state al plugin (detiene plugin)
    // Defining fail state to plugin (stops plugin)
    SetFailState("database.cfg missing '%s' entry!", DB_CONF_NAME);
  }
}

/**
 * When the client connected will be inserted into the database
 * @param client 
 */
public void OnClientPostAdminCheck(int client) {
  // Verificando si el cliente es valid
  // Verifying if the client is valid
  if (IsValidEntity(client)) {
    // Verificando que el cliente no sea falso	
    // Verifying that the client is not false
    if (!IsFakeClient(client)) {
      // Verificando que el cliente tenga acceso a vip o moderador
      // Verifying that the client has access to vip or moderator
      if(CheckCommandAccess(client, "sm_fk", ADMFLAG_RESERVATION, true) || CheckCommandAccess(client, "sm_fk", ADMFLAG_GENERIC, true)) {
        char steamid[20], query[200];
        GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
        Format(query, sizeof(query), "INSERT OR IGNORE INTO vip (steamid) VALUES ('%s');", steamid);
        SQL_UnlockDatabase(g_dbConnection);
        SQL_FastQuery(g_dbConnection, query);
        SQL_UnlockDatabase(g_dbConnection);
      }
    }
  }
  counters[QUOTA][client] = 0;
  counters[USE_VIP][client] = 0;
  counters[USE_DROP][client] = 0;
}
#endif

/**
 * Command to give laser to the client
 * @param  client {integer}
 * @param  args   {integer}
 */
public Action Command_Laser(int client, int args) {
  // Verificando que el cliente sea valido
  // Verifying that the customer is valid
  if(IsValidPlayer(client)) {
    // Dando el laser al jugador
    // Giving the laser to the player
    VipWeapon(client, 26);
  }
  return Plugin_Handled;
}

/**
 * Buy command
 * @param  client {integer}
 * @param  args   {integer}
 */
public Action Command_Buy(int client, int args) {
  CPrintToChat(client, "\x05[\x04VIP\x05]\x05 Visit: {blue}vip.l4d.dev");
  return Plugin_Handled;
}

/**-
 * Set aura for player
 * @param  client {integer}
 * @param  args   {integer}
 */
public Action Commant_SetAura(int client, int args) {
  // Verificando que tenga al menos un argumento
  // Verifying that you have at least one argument
  if (args >= 1) {
    char arg[65], target_name[MAX_TARGET_LENGTH];
    GetCmdArg(1, arg, sizeof(arg));
    int target_list[MAXPLAYERS], target_count;
    bool tn_is_ml;

    if ((target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, 0, target_name, sizeof(target_name), tn_is_ml)) <= 0) {
      ReplyToTargetError(client, target_count);
      return Plugin_Handled;
    } else {
      for (int i = 0; i < target_count; i++) {
        if(player_aura[target_list[i]] > 0) {
          SetAura(target_list[i], player_aura[target_list[i]]);
        }
      }
      return Plugin_Handled;
    }
  } else {
    ReplyToCommand(client, "setaura <#userid|name>");
    return Plugin_Handled;
  }
}

/**
 * Event: When the client disconnects
 * @param  event         {Event}
 * @param  name          {string}
 * @param  dontBroadcast {boolean}
 */
public Action Event_Disconnect(Event event, const char[] name, bool dontBroadcast) {
  // Defining cliente
  int client = GetClientOfUserId(event.GetInt("userid"));
  // Removing aura
  player_aura[client] = 0;
  // Counters to Zero
  counters[USE_VIP][client] = 0;
  counters[USE_DROP][client] = 0;
  counters[QUOTA][client] = 0;
  // Checking if database was used
  #if !USE_DB
  // Limpiando timers 
  // Clearing timers
  for (int i = 0; i < NUMBER_WEAPONS; i++) {
    weapon_timers[client][i] = 0;
  }
  
  #endif
}

/**
 * Comando para menu VIP
 * @param  client {integer}
 * @param  args   {integer}
 */
public Action Command_VIP(int client, int args) {
  // Verificanado si es un cliente valido
  // Verified if you are a valid client
  if(IsValidPlayer(client)) {
    // Creando menu del vip
    // Creating menu of vip
    BuildVipMenu(client);
  }
  return Plugin_Handled;
}

/**
 * Aura menu command
 * @param  client {integer}
 * @param  args   {integer}
 */
public Action Command_Aura(int client, int args) {	
  // Verificanado si es un cliente valido
  // Verified if you are a valid client
  if(IsValidPlayer(client)) {
    // Creando menu del aura
    // Creating aura menu
    BuildAuraMenu(client);
  }
  return Plugin_Handled;
}

/**
 * Creating vip menu
 * @param client {integer}
 */
void BuildVipMenu(int client) {
  Menu menu = CreateMenu(HandleVIPMenu);
  menu.SetTitle("VIP Menu");
  menu.AddItem("", "Melees");
  menu.AddItem("", "Weapons");
  menu.AddItem("", "Misc");
  menu.AddItem("", "Aura");
  menu.Display(client, MENU_TIME_FOREVER);
}

/**
 * Handling selection in the menu vip
 * @param  menu   {Menu}
 * @param  action {MenuAction}
 * @param  client {integer}
 * @param  index {integer}
 */
public int HandleVIPMenu(Menu menu, MenuAction action, int client, int index) {
  if( action == MenuAction_Select ) {
    switch (index) {
      case 0: BuildWeaponMenu(client, TYPE_MELEE, "Melee menu");
      case 1: BuildWeaponMenu(client, TYPE_WEAPON, "Weapon menu");
      case 2: BuildWeaponMenu(client, TYPE_MISC, "Misc menu");
      case 3: BuildAuraMenu(client);
    }
  }
}

/**
 * Añadiendo condigo al command drop
 * @param  client 
 * @param  args   
 * @return void
 */
public Action Command_drop(int client, int args) {
  // Verificando si es un usuario valido
  // Checking if is a valid player
  if (IsValidPlayer(client)) {
    // Sumando drop
    counters[USE_DROP][client] += 1;
    // Verificando si el jugador ya usp vip y es la primera vez que usa drop
    if (counters[USE_VIP][client] >= 1 && counters[USE_DROP][client] == 1) { 	
      // Aviso de penalizacion
      if (counters[QUOTA][client] > 0)  {
        counters[QUOTA][client] -= 1;
      }
      // Imprimiendo mensaje al cliente
      CPrintToChat(client, "\x05[\x04VIP\x05]\x03 If you drop a weapon from vip again, you will be penalized with 0 of quota.");
      // Quitando puntos al jugador
      ServerCommand("sm_givepoints #%d -20", GetClientUserId(client));
    // Verificando si el jugador ya ha utilizado el vip mas de dos veces y ha dropeado el arma mas de dos veces
    } else if (counters[USE_VIP][client] >= 2 && counters[USE_DROP][client] >= 2) {
      // Penalizacion al usuario
      int points = 2 * (counters[USE_VIP][client] * 10);
      points = (points > 100) ? 100 : points;
      // Definiendo cuota en 0
      counters[QUOTA][client] = 0;
      // Definiendo el numero de vip como 6
      counters[USE_VIP][client] = 6;
      // Imprimiendo mensaje al cliente
      CPrintToChat(client, "\x05[\x04VIP\x05]\x03 You have released more than two weapon. You will be penalized with 0 of quota.");
      // Quitando puntos al jugador
      ServerCommand("sm_givepoints #%d -%d", GetClientUserId(client), points);
    }
  }
}

/**
 * Funcion para dar un arma a un jugador vip
 * @param client {integer} 
 * @param index  {integer}
 */
public void VipWeapon(int client, int index) {
  // Verificando que el jugador se valido
  // Checking if player is valid
  if(IsValidPlayer(client)) {
    // Añadiendo +1 al uso de veces que ha usado el vip
    // Adding +1 to number of times that player use vip
    counters[USE_VIP][client]++;
    // Verificando si se utilizara una base de datos
    // Checking if a database is used
    #if USE_DB
    // Inicializando variables de steam id y query
    // Initializing steam id and query variables
    char steamid[30], query[128];	
    // Obteniendo el Steam Id del jugador
    // Getting the Steam Player ID
    GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
    // Formateando consulta
    // Formatting Query
    Format(query, sizeof(query), "SELECT %s FROM vip WHERE steamid = '%s';", weapons_list[index][WEAPON_NAME], steamid);
    // Instanciando resultados
    // Instantiating results
    DBResultSet result;
    // Solicitando resultados
    // Requesting Results
    if ((result = SQL_Query(g_dbConnection, query)) != null) {
      // Obteniendo resultados
      // Getting Results
      if(result.FetchRow()) { 
        // Obteniendo la ultima ves que se utilizo el arma
        // Obtaining the last time the weapon was used
        int lastget = result.FetchInt(0);
        // variable para buffer
        // Variable to buffer
        char buffer[32];
        // Obteniendo el tiempo actual
        // Getting current time
        int time = GetTime();
        // Igualando buffer al nombre del arma
        // Match buffer to weapon name
        buffer = weapons_list[index][WEAPON_NAME];
        // Remplazando _ en nombre del arma
        // Replacing _ in the name of the weapon
        ReplaceString(buffer, 32, "_", " ");
        // Comparando el tiempo actual contra la ultima vez que se utilizo 
        // Comparing the current time against the last time it was used
        if(time > lastget) {
          // Formateando consulta
          // Formatting Query
          Format(query, sizeof(query), "UPDATE vip SET %s=%d WHERE steamid = '%s';", weapons_list[index][WEAPON_NAME], (time + StringToInt(weapons_list[index][WEAPON_TIME])), steamid);
          // Enviando ultima ves que se tomo el arma
          // Sending last time the gun was taken
          if ((result = SQL_Query(g_dbConnection, query)) != null) {
            // Verificando que no sea un upgrade 
            // Verifying that it is not an upgrade
            if(!StrEqual(weapons_list[index][WEAPON_SLOT],UPGRADE)) {
              // Obteniendo el slot
              // Getting the slot
              int slot = GetPlayerWeaponSlot(client, StringToInt(weapons_list[index][WEAPON_SLOT]));
              // Comprobando que el slot sea valido
              // Verifying that the slot is valid
              if (slot > -1)  {
                // Removiendo el arma que tiene en el slot
                // Removing the weapon in the slot
                RemovePlayerItem(client, slot);
              }
            }
            // Dando arma al cliente
            // Giving the client a weapon
            give_weapon(client, weapons_list[index][WEAPON_NAME]);
            // Imprimiendo el arma que se recibio
            // Printing the weapon that was received
            CPrintToChat(client, "\x05[\x04VIP\x05]\x05 You take a {blue}%s", buffer);
          } else {
            CPrintToChat(client, "\x05[\x04VIP\x05]\x05 Something went wrong, please notify {blue}Aleexxx");
            LogError("Error en VipWeaponSQL()->query = '%s'", query);
          }
        } else {  
          // Calculando tiempo restante
          // Calculating Remaining Time
          time = (lastget - time);
          // Si tiempo es mayor a un minuto
          // If time is greater than one minute
          if(time > 60) {
            // Se divide para ver cuantos minutos faltan
            // Split to see how many minutes are left
            time = time/60;
            // Se imprime el tiempo faltante
            // The missing time is printed
            CPrintToChat(client, "\x05[\x04VIP\x05]\x05 You need to wait{blue} %d\x05 minutes to take a {blue}%s", time, buffer);
          } else {
            // En caso de que sean segundos, se imprime los segundos restantes
            // If they are seconds, the remaining seconds are printed
            CPrintToChat(client, "\x05[\x04VIP\x05]\x05 You need to wait{blue} %d\x05 seconds to take a {blue}%s", time, buffer);
          }
        }
      }
    } else {
      CPrintToChat(client, "\x05[\x04VIP\x05]\x05 Something went wrong, please notify {blue}Aleexxx");
      LogError("Error en VipWeaponSQL()->query = '%s'", query);
    }

    // En caso contrario que se desee utilizar el vip sin base de datos
    // Otherwise you want to use vip without database
    #else
    // Inicializando variables
    // Initializing variables
    char buffer[32];
    // Obteniendo el tiempo actual
    // Getting current time
    int time = GetTime();
    // Igualando buffer al nombre del arma
    // Match buffer to weapon name
    buffer = weapons_list[index][WEAPON_NAME];
    // Replacing _ in the name of the weapon
    ReplaceString(buffer, 32, "_", " ");
    // Comparando el tiempo actual contra el ultimo 
    // Comparing the current time against the last
    if(time > weapon_timers[client][index]) {
      // Guardando la ultima ves que se obtuvo este arma
      // Saving the last time this weapon was obtained
      weapon_timers[client][index] = time + StringToInt(weapons_list[index][WEAPON_TIME]);
      // Verificando que no sea un upgrade 
      // Verifying that it is not an upgrade
      if(!StrEqual(weapons_list[index][WEAPON_SLOT],UPGRADE)) {
        // Obteniendo el slot
        // Getting the slot
        int slot = GetPlayerWeaponSlot(client, StringToInt(weapons_list[index][WEAPON_SLOT]));
        // Comprobando que el slot sea valido
        // Verifying that the slot is valid
        if (slot > -1)  {
          // Removiendo el arma que tiene en el slot
          // Removing the weapon in the slot
          RemovePlayerItem(client, slot);
        }
      }
      // Dando arma al cliente
      // Giving the client a weapon
      give_weapon(client, weapons_list[index][WEAPON_NAME]);
      // Imprimiendo el arma que se recibio
      // Printing the weapon that was received
      CPrintToChat(client, "\x05[\x04VIP\x05]\x05 You take a {blue}%s", buffer);
    } else {  
      // Calculando tiempo restante
      // Calculating Remaining Time
      time = (weapon_timers[client][index] - time);
      // Si tiempo es mayor a un minuto
      // If time is greater than one minute
      if(time > 60) {
        // Se divide para ver cuantos minutos faltan
        // Split to see how many minutes are left
        time = time/60;
        // Se imprime el tiempo faltante
        // The missing time is printed
        CPrintToChat(client, "\x05[\x04VIP\x05]\x05 You need to wait{blue} %d\x05 minutes to take a {blue}%s", time, buffer);
      } else {
        // En caso de que sean segundos, se imprime los segundos restantes
        // If they are seconds, the remaining seconds are printed
        CPrintToChat(client, "\x05[\x04VIP\x05]\x05 You need to wait{blue} %d\x05 seconds to take a {blue}%s", time, buffer);
      }
    }

    #endif
  }

}

/**
 * Build weapon menu
 * @param client {integer}	: cliente que usara el menu
 * @param item   {string}	: tipo de item que generara el menu
 * @param title  {string}	: Titulo del menu
 */
void BuildWeaponMenu(int client, char[] item, char[] title) {
  // Creando menu
  // Creating menu
  Menu menu = CreateMenu(HandleWeaponsMenu);
  // Asignando titulo
  // Assigning the title
  menu.SetTitle(title);
  // Inicializando buffer
  // Initializing buffer
  char buffer[32];
  // Obteniendo el tipo de vip
  // Getting the type of vip
  int mytypevip = type_vip(client), level = 0;
  // Recorriendo lista de armas
  // Wrapping Arms List
  for( int i = 0; i < NUMBER_WEAPONS; i++ )  {
    // Verificando si el tipo de arma es la deseada a mostrar
    // Checking if the type of weapon is the one to be displayed
    if(StrEqual(weapons_list[i][WEAPON_TYPE], item)) {
      // Obteniendo el nivel del arma
      // Obtaining the level of the weapon
      level = StringToInt(weapons_list[i][WEAPON_LEVEL]);
      // verificando si el usuario puede obtener esta arma
      // Verifying if the user can obtain this weapon
      if(mytypevip >= level) {
        // Obteniendo nombre del arma 
        // Obtaining gun name
        buffer = weapons_list[i][WEAPON_NAME];
        // Replazando _ del nombre sobre buffer
        // Replacing _ name over buffer
        ReplaceString(buffer, 32, "_", " ");
        // Creando variable para guardar index
        // Creating variable to save index
        char index[32];
        // Convirtiendo index actual en string
        // Converting current index to string
        Format(index, sizeof(index), "%d", i);
        // añadiendo item al menu
        // Adding item to the menu
        menu.AddItem(index, buffer);
      }
    }
  }
  // Definiendo boton de volver como verdadero
  menu.ExitBackButton = true;
  // Definiendo boton de Salida como verdadero
  menu.ExitButton = true;
  // Mostrando menu
  menu.Display(client, MENU_TIME_FOREVER);
}

/**
 * Manages the selection that was made in the weapons menu
 * @param  menu   {Menu}
 * @param  action {MenuAction}
 * @param  client {integer}
 * @param  accion {integer}
 */
public int HandleWeaponsMenu(Menu menu, MenuAction action, int client, int accion) {
  // Checking the user's selection
  switch(action) {
    // In case the user wishes to exit
    case MenuAction_End: delete menu;
    // In case the user wishes to return to the main menu
    case MenuAction_Cancel: if(accion == MenuCancel_ExitBack) BuildVipMenu(client);
    // In case the user selects an element
    case MenuAction_Select: {
      // Initializing buffer
      char buffer[32];
      // Getting the selected action and buffering
      menu.GetItem(accion, buffer, sizeof(buffer));
      // Converting string index to integer
      int index = StringToInt(buffer);
      // Giving the player a gun
      VipWeapon(client, index);
      // Returning to the main menu
      BuildVipMenu(client);
    }
  }
}

/**
 * Create the Aura menu
 * @param client {Integer}
 */
void BuildAuraMenu(int client) {
  Menu menu = CreateMenu(HandleAura);
  menu.SetTitle("Aura Menu:");
  menu.AddItem("16711680", "Blue");
  menu.AddItem("3355647", "Red");
  menu.AddItem("65280", "Green");
  menu.AddItem("16724889", "Purple");
  menu.AddItem("55295", "Yellow");
  menu.AddItem("17919", "Orange");
  menu.AddItem("16776960", "Aqua");
  menu.AddItem("9639167", "Pink");
  menu.ExitBackButton = true;
  menu.ExitButton = true;
  menu.Display(client, MENU_TIME_FOREVER);
}

/**
 * Manages aura menu selection
 * @param  menu
 * @param  action
 * @param  client
 * @param  index
 */
public int HandleAura(Menu menu, MenuAction action, int client, int index) {
  // Checking action
  switch(action) {
    // In case you want to delete the menu
    case MenuAction_End: {
      delete menu;
    }
    // On cancel
    case MenuAction_Cancel: {
      // Checking if index is equal to return
      if(index == MenuCancel_ExitBack) {
        // Returning to main menu
        BuildVipMenu(client);
      }
    }
    // Selecting an item
    case MenuAction_Select: {
      // Variable to save index
      char buffer[12];
      // Retrieving the selected index and buffering
      menu.GetItem(index, buffer, sizeof(buffer));
      // Converting string color to integer
      int color = StringToInt(buffer);
      // Defining aura
      SetAura(client, color);
      // Returning to main menu
      BuildVipMenu(client);
    }
  }
}

/**
 * Set aura to a player
 * @param client {integer}
 * @param color  {integer}
 */
public void SetAura(int client, int color) {
  SetEntProp(client, Prop_Send, "m_iGlowType", 3);
  SetEntProp(client, Prop_Send, "m_glowColorOverride", color);
  player_aura[client] = color;
}

/**
 * Giving a gun to a player
 * @param client {integer}
 * @param weapon {string}
 */
public void give_weapon(int client, char[] weapon) {
  ServerCommand("sm_gw #%d %s", GetClientUserId(client), weapon);
  PrintToConsole(client, "[debug] sm_gw #%d %s", GetClientUserId(client), weapon);
}

/**
 * Checking if the player is valid
 * @param  client {integer}
 * @return {boolean}
 */
public bool IsValidPlayer(int client)
{
  // Verifying that the player is VIP
  if( CheckCommandAccess(client, "sm_fk", ADMFLAG_RESERVATION, true) ||
    CheckCommandAccess(client, "sm_fk", ADMFLAG_GENERIC, true) ||
    (g_bPoints && TYSTATS_GetPoints(client) >= 5000)
  ) {
    // Verifying that player is online, live, do not be fake, and be a survivor
    if(IsClientInGame(client) && IsPlayerAlive(client) && !IsFakeClient(client) && GetClientTeam(client) == 2) {
      return true;
    } else {
      CPrintToChat(client, "\x05[\x04VIP\x05]\x05 You must be a {blue}survivor\x05 and being {blue}alive\x05 to use this function!");
    }
  } else {
    CPrintToChat(client, "\x05[\x04VIP\x05]\x05 You not have permission to use this function, visit: {blue}vip.l4d.dev");
  }
  return false;
}

/**
 * Obtaining the type of player vip
 * @param  client {integer}
 * @return {integer} : 2 == PREMIUM, 1 == GOLD, 0 SILVER
 */
public int type_vip(int client) {
  // default
  int vip = 0;
  // Checking if you have vip premium or are a moderator
  if(CheckCommandAccess(client, "sm_fk", ADMFLAG_CUSTOM2, true) || CheckCommandAccess(client, "sm_fk", ADMFLAG_GENERIC, true)) {
    vip = 2;
  // Checking if you have vip gold
  } else if(CheckCommandAccess(client, "sm_fk", ADMFLAG_CUSTOM1, true)) {
    vip = 1;
  }
  return vip;
}