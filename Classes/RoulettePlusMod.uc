class RoulettePlusMod extends XComMod Within ModBridge
	DependsOn(RoulettePlus, RPCheckpoint)
	config(RoulettePlus);

struct TSemiSPerkPos
{
	var array<int> Poss;
	var string perk;
};


var array <string> arrPerk;
var array <TAliasArr> arrAlias;
var config float RPConfigVer;
var config array <TAlias> PerkAliases;
var config array <string> SniperPerks;
var config array <string> ScoutPerks;
var config array <string> RocketeerPerks;
var config array <string> GunnerPerks;
var config array <string> MedicPerks;
var config array <string> EngineerPerks;
var config array <string> AssaultPerks;	
var config array <string> InfantryPerks;
var config array <string> AllMECPerks;
var config array <string> AllBioPerks;
var config array <string> AllSoldierPerks;
var config array <string> JaegerPerks;
var config array <string> PathfinderPerks;
var config array <string> ArcherPerks;
var config array <string> GoliathPerks;
var config array <string> GuardianPerks;
var config array <string> ShogunPerks;
var config array <string> MarauderPerks;
var config array <string> ValkyriePerks;
var config array <string> IncompatiblePerks1;
var config array <string> IncompatiblePerks2;
var config array <string> ChainPerks1;
var config array <string> ChainPerks2;
var config array <string> ChoicePerks1;
var config array <string> ChoicePerks2;
var config array <string> MergePerk1;
var config array <string> MergePerk2;
var config array <int> MergePerkClass;
var config array <string> RequiredPerk1;
var config array <TRequiredPerk> RequiredPerk2;
var config array <int> RequiredPerkClass;
var config array <TStaticPerks> StaticPerks;
var config array <TSemiStatic> SemiStaticPerks;
var config array <TPerkStats> PerkStats;
var config array <TPerkChance> PerkChance;
var config bool IsMECRandom;
var config bool IsAugmentDiscounted;
var config float AugmentDiscount;
var config int PoolPrioity;
var config string strMergePerkLabel;
var config string strMergePerkDes;
var config string strMergePerkColor;
var config string strRPSWDesc;
var config bool bHideEmptyStatStr;
var config bool UseVanillaRolls;
var config bool MECxpLoss;
var config bool MECChops;
var config bool MECMedalWait;
var config bool IsCommandFree;
var config bool UseOldITZInteraction;
var config bool UseLWBetaRnGInteraction;
var config bool SplitConfig;
var RPPerksMod m_kRPPerksMod;
var RPCheckPoint m_kRPCheckpoint;
`ifdebug var RPCheckPointRec m_kRPCheckpointRec; `endif
var RPCheats m_kRPCheats;
var XGStrategySoldier m_kSold, m_kSold1;
var Object m_kValObj;

function Object Object(optional Object inObj, optional bool bForce)
{
	if(inObj == none && !bForce)
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed return " $ `ShowVar(m_kValObj, Object), verboseLog, 'ModBridge_RP');
		return m_kValObj;
	}
	else
	{
		`Log("\"" $ GetCallingMod() $ "\" accessed store " $ `ShowVar(inObj, Object) $ ", " $ `ShowVar(bForce), verboseLog, 'ModBridge_RP');
		m_kValObj = inObj;
		return none;
	}
}

function WorldInfo WORLDINFO()
{
	return class'Engine'.static.GetCurrentWorldInfo();
}

function PlayerController PLAYERCONTROLLER()
{
	return WORLDINFO().GetALocalPlayerController();
}

function XGFacility_Barracks BARRACKS()
{
    return XComHeadquartersGame(WORLDINFO().Game).GetGameCore().GetHQ().m_kBarracks;
}

function XGSoldierUI SOLDIERUI()
{
	return XGSoldierUI(XComHQPresentationLayer(XComPlayerController(PLAYERCONTROLLER()).m_Pres).GetMgr(class'XGSoldierUI',,, true));
}

function XGStrategySoldier SOLDIER()
{
	return SOLDIERUI().m_kSoldier;
}


simulated function StartMatch()
{
	local array<string> arrStr;
	local XGStrategySoldier kSold;

	if(functionName == "SecondWaveTitleAmmend")
	{
		SWTitleAmmend(int(functParas));
	}
	if(functionName == "SecondWaveDescAmmend")
	{
		if(functParas == "4")
			StrValue0(StrValue0() $ class'XComLocalizer'.static.ExpandString("<font color='#F78000'> " $ strRPSWDesc $ "</font>"));
	}

	if(functionName == "SwitchCheatManager")
	{
		if(functParas == "Strategy")
		{
			ModCheatClass = class'RPCheats';
		}
		if(functParas == "Tactical")
		{
			ModCheatClass = class'RPTacticalCheats';
		}
	}


	if(functionName == "AssignRandomPerks_Overwrite")
	{
		if(XGStrategySoldier(Object()) != none)
			m_kSold = XGStrategySoldier(Object());
		//GetSoldier(StrValue0());
		if(UseVanillaRolls)
		{
			VanRandPerks();
		}
		else if(m_kSold.IsAugmented() && !IsMECRandom)
		{
			GetVanMECPerks();
		}
		else
		{
			GetRandomPerks();
		}
		m_kSold = none;
		Object(none, true);
		StrValue0("True");
		bModReturn = true;
	}

	if(functionName == "GetPerkInClassTree")
	{
		arrStr = SplitString(functParas);

		if(XGStrategySoldier(Object()) != none)
			m_kSold = XGStrategySoldier(Object());
		//GetSoldier(StrValue0());

		if(m_kSold != none)
			kSold = m_kSold;
		else
			kSold = SOLDIER();

		`Log(`ShowVar(kSold), verboseLog, 'GetPerkInClassTree');

		`logd("Loriendal" @ `ShowVar(arrStr[2], bIsPsiTree));
		`logd("Loriendal" @ bool(arrStr[2]) ? "True" : "False");
		`logd("Loriendal" @ `ShowVar(functParas));

		if(bool(arrStr[2]) == bool("false") && kSold.IsOptionEnabled(4) && arrStr[0] != "1")
		{
			`logd("GetPerkInClassTree");
			`logd(`ShowVar(kSold.GetRank()), kSold.IsAugmented());

			if(kSold.IsAugmented())
			{
				if(!(kSold.HasPerk(kSold.GetPerkInClassTree(1, 0)) || kSold.HasPerk(kSold.GetPerkInClassTree(1, 1)) || kSold.HasPerk(kSold.GetPerkInClassTree(1, 2))))
				{
					`logd("Doesn't have first perk");
					`logd(`ShowVar(FindSoldierInStorage(, kSold)));

					if(FindSoldierInStorage(, kSold) == -1)
					{
						`logd("didn't find soldierStor");
						CreateSoldierStor(kSold);
					}
					IntValue0(-1, true);
					m_kRPPerksMod.ASCSetUnit(string(kSold));
					m_kRPPerksMod.ASCPerks("HasPerk", 136);
					if(IntValue0() == 0)
					{
						`logd("OFA not set");
						FlushRandomTree(kSold);
						m_kRPPerksMod.ASCPerks("GivePerk", 136);
					}
				}

			}

			if(!kSold.IsAugmented() || IsMECRandom)
			{
				if(isSoldierNewType(kSold))
					IntValue0(NewRandomTree(kSold, -1)[(3 * int(arrStr[0]) - 1) + int(arrStr[1]) - 2], true);
				else if(m_kSold.m_arrRandomPerks.Length > 0)
				{
					IntValue0(m_kSold.m_arrRandomPerks[(3 * int(arrStr[0]) - 1) + int(arrStr[1]) - 2], true);
				}
				else
				{
					IntValue0(0, true);
				}
			}
			bModReturn = true;
		}
		
		m_kSold = none;
		Object(none, true);
	}

	if(functionName == "FireRocketPerk")
	{
		if(XGStrategySoldier(Object()) != none)
			m_kSold = XGStrategySoldier(Object());
		//GetSoldier(StrValue0());

		if(m_kSold != none)
			kSold = m_kSold;
		else
			kSold = SOLDIER();
		
		if(kSold.GetClass() == 2)
		{
			kSold.LOCKERS().EquipLargeItem(kSold, 218, 1);
			kSold.OnLoadoutChange();
			
			StrValue0("True");
		}
		
		m_kSold = none;
		Object(none, true);
	}

	if(functionName == "CanNotAugment")
	{
		if(XGStrategySoldier(Object()) != none)
			m_kSold = XGStrategySoldier(Object());
		//GetSoldier(StrValue0());
		CanNotAugment();
		if(StrValue0() != "True")
				StrValue0("False");

		m_kSold = none;
		Object(none, true);
	}

/*	if(functionName == "CanNotAugment_skipDefaults")
	{
		StrValue0("True");
	}
*/

	if(functionName == "AugmentRestriction")
	{
		if(XGStrategySoldier(Object()) != none)
			m_kSold = XGStrategySoldier(Object());
		//GetSoldier(StrValue0());
		AugmentRestriction();
		if(m_kSold.HasAnyMedal())
		{
			if(MECMedalWait)
				kSold.BARRACKS().RollStat(kSold, 0, 0);
			else
				GiveBackMedals();
		}
		
		m_kSold = none;
		Object(none, true);
	}

	if(functionName == "BuildAugmentMenuOption")
	{
		if(XGStrategySoldier(Object()) != none)
			m_kSold = XGStrategySoldier(Object());
		//GetSoldier(StrValue0());

		`Log(`ShowVar(m_kSold),, 'BuildAugmentMenuOption');
		
		BuildAugmentMenuOption();
		
		m_kSold = none;
		Object(none, true);
	}

	if(functionName == "UISoldierAugmentationInit_Setlabels_Overwrite")
	{
		if(!MECxpLoss)
			StrValue1(Split(functParas, ". ", true), true);
	}


	if(functionName == "PerkMerge")
	{
		if(XGStrategySoldier(Object()) != none)
			m_kSold = XGStrategySoldier(Object());
		//GetSoldier(StrValue0());
		PerkMerge(int(functParas));
		
		m_kSold = none;
		Object(none, true);
	}

	if(functionName == "CanAffordAugment")
	{
		arrStr = SplitString(functParas);
		
		if(BARRACKS().IsOptionEnabled(4) && IsAugmentDiscounted)
		{
			if(BARRACKS().GetResource(0) >= (int(arrStr[0]) * (AugmentDiscount / 100)) && BARRACKS().GetResource(7) >= (int(arrStr[1]) * (AugmentDiscount / 100)))
				StrValue0("True");
			else
				StrValue0("False");

			IntValue0(int(arrStr[0]) * (AugmentDiscount / 100.00), true);
			IntValue1(int(arrStr[1]) * (AugmentDiscount / 100.00), true);
		}	
	} 

	if(functionName == "PayAugmentCost")
	{
		arrStr = SplitString(functParas);
		
		if(BARRACKS().IsOptionEnabled(4) && IsAugmentDiscounted)
		{
			BARRACKS().AddResource(0, -(int(arrStr[0]) * (AugmentDiscount / 100.00)));
			BARRACKS().AddResource(7, -(int(arrStr[1]) * (AugmentDiscount / 100.00)));
			
			StrValue0("True");
		}	
	}

	if(functionName == "OnAcceptPromotion_Overwrite")
	{
		if(XGStrategySoldier(Object()) != none)
			m_kSold1 = XGStrategySoldier(Object());
		//GetSoldier(StrValue0());
	}
	if(functionName == "OnAcceptPromotion_After")
	{
		m_kSold = m_kSold1;
		if(m_kSold.IsOptionEnabled(4) && SOLDIERUI().m_iCurrentView != 2)
		{
			PerkMerge(m_kSold.GetPerkInClassTree(SOLDIERUI().GetAbilityTreeBranch(), SOLDIERUI().GetAbilityTreeOption(), false));
	
			if(isSoldierNewType(m_kSold1) && SOLDIERUI().GetAbilityTreeBranch() != 1)
			{
				NewPerkStats(((SOLDIERUI().GetAbilityTreeBranch() - 1) * 3) + SOLDIERUI().GetAbilityTreeOption());
			}
			else
			{
				OldPerkStats(((SOLDIERUI().GetAbilityTreeBranch() - 1) * 3) + SOLDIERUI().GetAbilityTreeOption());
			}

			if(m_kSold1.IsAugmented() && IsMECRandom && SOLDIERUI().GetAbilityTreeBranch() == 1)
			{
				if(UseVanillaRolls)
					VanRandPerks();
				else
					GetRandomPerks();
			}

		}
		m_kSold = none;
		m_kSold1 = none;
		Object(none, true);
	}

	if(functionName == "ModInit")
	{
		init();
	}

	m_kRPPerksMod.StartMatch();

}

function init()
{
	local bool CC, MRA;

	ChooseConfig();

	m_kRPCheckpoint = GetCheckpoint();

	m_kRPPerksMod = new (outer) class'RPPerksMod';
	//WORLDINFO().Game.SetTimer(1.0, true, 'CreateCheats', self);

	MRA = ModRecordActor("Transport", class'RPCheckpoint');

	`ifdebug
		m_kRPCheckpointrec = GetCheckpointRec();
		ModRecordActor("Transport", class'RPCheckpointRec');
	
		if(class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToDestroy.Find(class'RPCheckpointRec') == -1)
			class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToDestroy.AddItem(class'RPCheckpointRec');
	`endif

	if(class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToDestroy.Find(class'RPCheckpoint') == -1)
		class'Mod_Checkpoint_StrategyTransport'.default.ActorClassesToDestroy.AddItem(class'RPCheckpoint');



	createPerkArray();

	CC = CheckConfig();

	if(CC)
	{
		ModInitError = "Config has major error";
	}
	if(m_kRPCheckpoint == none)
	{
		if(ModInitError != "")
			ModInitError $= ", ";

		ModInitError $= "Checkpoint class not initalised";
	}
	if(m_kRPPerksMod == none)
	{
		if(ModInitError != "")
			ModInitError $= ", ";

		ModInitError $= "PerkMod class not initalised";
	}
	if(arrPerk.Length == 0)
	{
		if(ModInitError != "")
			ModInitError $= ", ";

		ModInitError $= "Perk array not initalised";
	}
	if(arrAlias.Length == 0)
	{
		if(ModInitError != "")
			ModInitError $= ", ";

		ModInitError $= "Alias array not initalised";
	}
	if(!MRA)
	{
		if(ModInitError != "")
			ModInitError $= ", ";

		ModInitError $= "adding Checkpoint class to CheckpointRecord failed";
	}
	if(ModInitError != "")
		ModInitError $= ".";
}

function RPCheckpoint GetCheckpoint()
{
	local RPCheckpoint RPChkpnt;

	foreach WORLDINFO().AllActors(class'RPCheckpoint', RPChkpnt)
	{
		break;
	}

	if(RPChkpnt == none)
	{
		RPChkpnt = WORLDINFO().Spawn(class'RPCheckpoint', PLAYERCONTROLLER());
	}
	return RPChkpnt;
}

`ifdebug
function RPCheckpointRec GetCheckpointRec()
{
	local RPCheckpointRec RPChkpnt;

	foreach WORLDINFO().AllActors(class'RPCheckpointRec', RPChkpnt)
	{
		break;
	}

	if(RPChkpnt == none)
	{
		RPChkpnt = WORLDINFO().Spawn(class'RPCheckpointRec', PLAYERCONTROLLER());
	}
	return RPChkpnt;
}
`endif

/*
`if(`isdefined(debug))
function CreateCheats()
{
	`logde("entered createcheats");

	if(PLAYERCONTROLLER() != none && XComHeadquartersGame(XComGameInfo(WORLDINFO().Game)) != none)
	{
		`logde("playercontroller not initalized, returning");
		return;
	}

	WORLDINFO().Game.ClearTimer('CreateCheats', self);

	PLAYERCONTROLLER().CheatClass = class'RPCheats';
	PLAYERCONTROLLER().CheatManager = new (XComHeadquartersController(PLAYERCONTROLLER())) class'RPCheats';

	`logde("playercontroller=" @ string(PLAYERCONTROLLER()));
	`logde("RPCheats=" @ string(m_kRPCheats));
}
`endif
*/


function ChooseConfig()
{

	if(RPConfigVer < 2.0)
	{
		SniperPerks = class'RoulettePlus'.default.SniperPerks;
		ScoutPerks = class'RoulettePlus'.default.ScoutPerks;
		RocketeerPerks = class'RoulettePlus'.default.RocketeerPerks;
		GunnerPerks = class'RoulettePlus'.default.GunnerPerks;
		MedicPerks = class'RoulettePlus'.default.MedicPerks;
		EngineerPerks = class'RoulettePlus'.default.EngineerPerks;
		AssaultPerks = class'RoulettePlus'.default.AssaultPerks;
		InfantryPerks = class'RoulettePlus'.default.InfantryPerks;
		AllMECPerks = class'RoulettePlus'.default.AllMECPerks;
		AllBioPerks = class'RoulettePlus'.default.AllBioPerks;
		AllSoldierPerks = class'RoulettePlus'.default.AllSoldierPerks;
		JaegerPerks = class'RoulettePlus'.default.JaegerPerks;
		PathfinderPerks = class'RoulettePlus'.default.PathfinderPerks;
		ArcherPerks = class'RoulettePlus'.default.ArcherPerks;
		GoliathPerks = class'RoulettePlus'.default.GoliathPerks;
		GuardianPerks = class'RoulettePlus'.default.GuardianPerks;
		ShogunPerks = class'RoulettePlus'.default.ShogunPerks;
		MarauderPerks = class'RoulettePlus'.default.MarauderPerks;
		ValkyriePerks = class'RoulettePlus'.default.ValkyriePerks;

		IncompatiblePerks1 = class'RoulettePlus'.default.IncompatiblePerks1;
		IncompatiblePerks2 = class'RoulettePlus'.default.IncompatiblePerks2;
		ChainPerks1 = class'RoulettePlus'.default.ChainPerks1;
		ChainPerks2 = class'RoulettePlus'.default.ChainPerks2;
		ChoicePerks1 = class'RoulettePlus'.default.ChoicePerks1;
		ChoicePerks2 = class'RoulettePlus'.default.ChoicePerks2;
		RequiredPerk1 = class'RoulettePlus'.default.RequiredPerk1;
		RequiredPerk2 = class'RoulettePlus'.default.RequiredPerk2;
		RequiredPerkClass = class'RoulettePlus'.default.RequiredPerkClass;
		StaticPerks = class'RoulettePlus'.default.StaticPerks;
		SemiStaticPerks = class'RoulettePlus'.default.SemiStaticPerks;
		PerkChance = class'RoulettePlus'.default.PerkChance;

		PerkAliases = class'RoulettePlus'.default.PerkAliases;
		PerkStats = class'RoulettePlus'.default.PerkStats;
		MergePerk1 = class'RoulettePlus'.default.MergePerk1;
		MergePerk2 = class'RoulettePlus'.default.MergePerk2;
		MergePerkClass = class'RoulettePlus'.default.MergePerkClass;
		
		IsMECRandom = class'RoulettePlus'.default.IsMECRandom;
		IsAugmentDiscounted = class'RoulettePlus'.default.IsAugmentDiscounted;
		AugmentDiscount = class'RoulettePlus'.default.AugmentDiscount;
		PoolPrioity = class'RoulettePlus'.default.PoolPrioity;
		strMergePerkLabel = class'RoulettePlus'.default.strMergePerkLabel;
		strMergePerkDes = class'RoulettePlus'.default.strMergePerkDes;
		UseVanillaRolls = class'RoulettePlus'.default.UseVanillaRolls;
		MECxpLoss = class'RoulettePlus'.default.MECxpLoss;
		MECChops = class'RoulettePlus'.default.MECChops;
		MECMedalWait = class'RoulettePlus'.default.MECMedalWait;

		
	}
	else if(SplitConfig)
	{
		SniperPerks = class'RPPools'.default.SniperPerks;
		ScoutPerks = class'RPPools'.default.ScoutPerks;
		RocketeerPerks = class'RPPools'.default.RocketeerPerks;
		GunnerPerks = class'RPPools'.default.GunnerPerks;
		MedicPerks = class'RPPools'.default.MedicPerks;
		EngineerPerks = class'RPPools'.default.EngineerPerks;
		AssaultPerks = class'RPPools'.default.AssaultPerks;
		InfantryPerks = class'RPPools'.default.InfantryPerks;
		AllMECPerks = class'RPPools'.default.AllMECPerks;
		AllBioPerks = class'RPPools'.default.AllBioPerks;
		AllSoldierPerks = class'RPPools'.default.AllSoldierPerks;
		JaegerPerks = class'RPPools'.default.JaegerPerks;
		PathfinderPerks = class'RPPools'.default.PathfinderPerks;
		ArcherPerks = class'RPPools'.default.ArcherPerks;
		GoliathPerks = class'RPPools'.default.GoliathPerks;
		GuardianPerks = class'RPPools'.default.GuardianPerks;
		ShogunPerks = class'RPPools'.default.ShogunPerks;
		MarauderPerks = class'RPPools'.default.MarauderPerks;
		ValkyriePerks = class'RPPools'.default.ValkyriePerks;

		IncompatiblePerks1 = class'RPRules'.default.IncompatiblePerks1;
		IncompatiblePerks2 = class'RPRules'.default.IncompatiblePerks2;
		ChainPerks1 = class'RPRules'.default.ChainPerks1;
		ChainPerks2 = class'RPRules'.default.ChainPerks2;
		ChoicePerks1 = class'RPRules'.default.ChoicePerks1;
		ChoicePerks2 = class'RPRules'.default.ChoicePerks2;
		RequiredPerk1 = class'RPRules'.default.RequiredPerk1;
		RequiredPerk2 = class'RPRules'.default.RequiredPerk2;
		RequiredPerkClass = class'RPRules'.default.RequiredPerkClass;
		StaticPerks = class'RPRules'.default.StaticPerks;
		SemiStaticPerks = class'RPRules'.default.SemiStaticPerks;
		PerkChance = class'RPRules'.default.PerkChance;

		PerkAliases = class'RPMisc'.default.PerkAliases;
		PerkStats = class'RPMisc'.default.PerkStats;
		MergePerk1 = class'RPMisc'.default.MergePerk1;
		MergePerk2 = class'RPMisc'.default.MergePerk2;
		MergePerkClass = class'RPMisc'.default.MergePerkClass;
	}
}

function bool CheckConfig()
{
	local int biopools, otherpools, rules, misc, settings;

	if(SniperPerks.Length == 0)
		++ biopools;

	if(ScoutPerks.Length == 0)
		++ biopools;
	
	if(RocketeerPerks.Length == 0)
		++ biopools;

	if(GunnerPerks.Length == 0)
		++ biopools;

	if(MedicPerks.Length == 0)
		++ biopools;

	if(EngineerPerks.Length == 0)
		++ biopools;

	if(AssaultPerks.Length == 0)
		++ biopools;

	if(InfantryPerks.Length == 0)
		++ biopools;

	if(AllMECPerks.Length == 0)
		++ otherpools;

	if(AllBioPerks.Length == 0)
		++ otherpools;

	if(AllSoldierPerks.Length == 0)
		++ otherpools;

	if(JaegerPerks.Length == 0)
		++ otherpools;

	if(PathfinderPerks.Length == 0)
		++ otherpools;

	if(ArcherPerks.Length == 0)
		++ otherpools;

	if(GoliathPerks.Length == 0)
		++ otherpools;

	if(GuardianPerks.Length == 0)
		++ otherpools;

	if(ShogunPerks.Length == 0)
		++ otherpools;

	if(MarauderPerks.Length == 0)
		++ otherpools;

	if(ValkyriePerks.Length == 0)
		++ otherpools;




	if(IncompatiblePerks1.Length == 0)
		++ rules;

	if(ChainPerks1.Length == 0)
		++ rules;

	if(ChoicePerks1.Length == 0)
		++ rules;

	if(RequiredPerk1.Length == 0)
		++ rules;

	if(StaticPerks.Length == 0)
		++ rules;

	if(SemiStaticPerks.Length == 0)
		++ rules;

	if(PerkChance.Length == 0)
		++ rules;



	if(PerkAliases.Length == 0)
		++ misc;

	if(PerkStats.Length == 0)
		++ misc;

	if(MergePerk1.Length == 0)
		++ misc;



	if(!IsMECRandom)
		++ settings;

	if(!IsAugmentDiscounted)
		++ settings;

	if(!UseVanillaRolls)
		++ settings;

	if(!MECxpLoss)
		++ settings;

	if(!MECChops)
		++ settings;

	if(!MECMedalWait)
		++ settings;

	if(!SplitConfig)
		++ settings;

	if(PoolPrioity == 0)
		++ settings;




	if(strMergePerkLabel == "" && strMergePerkDes == "")
	{
		ModError("Strings for MergePerk display not found");
	}
	else if(strMergePerkLabel == "")
	{
		ModError("String for MergePerk label not found");
	}
	else if(strMergePerkDes == "")
	{
		ModError("String for merged perk description label not found");
	}


	if(settings == 8)
		ModError("No settings seem to have been set in config");



	if(misc == 3)
		ModError("No misc found in config");


	if(rules == 7)
	{
		ModError("No rules found in config");
	}
	else if(rules > 2)
		ModError("Some rules are missing in config");


	if(otherpools == 11)
		ModError("No secondary perk pools found in config");


	if(biopools == 8)
	{
		if(AllBioPerks.Length == 0 && AllSoldierPerks.Length == 0)
			ModError("All main perk pools and both main encompassing pools missing in config");
		else
			ModError("No main perk pools found in config");
	}
	else if(biopools > 0)
	{
		if(AllBioPerks.Length == 0 && AllSoldierPerks.Length == 0)
		{
			ModError(string(biopools) @ "main perk pools and both main encompassing pools missing in config");
			return true;
		}
		else
			ModError(string(biopools) @ "main perk pools missing in config");
	}


	return false;

}

function SWTitleAmmend(int option)
{
	local string outstring;

	if(option == 4)
	{
		outstring = StrValue0();
		if(InStr(outstring, "(#4)") != -1)
			outstring = "+" $ Left(outstring, Len(outstring)-4) $ "PLUS+ (#4)";
		else
			outstring = "+" $ outstring $ " PLUS+";
	}

	StrValue0(class'XComLocalizer'.static.ExpandString(outstring));
}




function RemoveRandPerks(XGStrategySoldier kSoldier)
{
    local array<int> arrPerkTree;
    local int iTreeLength, I;

	m_kSold = kSoldier;

    if(isSoldierNewType(kSoldier))
    {
        iTreeLength = NewRandomTree(kSoldier, -2)[0];
        arrPerkTree = NewRandomTree(kSoldier, -1);
    }
	else
	{
		arrPerkTree = OldPerkTree(kSoldier);	
	}

    for(I = 3; I < 21; I++)
    {
		`Log(`ShowVar(arrPerkTree[I], perk) @ `ShowVar(GetMergedPerk(arrPerkTree[I]), GetMergedPerk) @ `ShowVar(bool(kSoldier.m_kChar.aUpgrades[GetMergedPerk(arrPerkTree[I])]), HasPerk),, 'RemoveMergePerk');
		if(GetMergedPerk(arrPerkTree[I]) != 0 && kSoldier.m_kChar.aUpgrades[GetMergedPerk(arrPerkTree[I])] % 2 == 1)
		{
			`Log(`ShowVar(kSoldier.m_kChar.aUpgrades[GetMergedPerk(arrPerkTree[I])], GetMergedPerk),, 'RemoveMergePerk_Before');
			kSoldier.m_kChar.aUpgrades[GetMergedPerk(arrPerkTree[I])] -= 1;
			`Log(`ShowVar(kSoldier.m_kChar.aUpgrades[GetMergedPerk(arrPerkTree[I])], GetMergedPerk),, 'RemoveMergePerk_After');
		}
        if(kSoldier.m_kChar.aUpgrades[arrPerkTree[I]] % 2 == 1)
        {
			kSoldier.m_kChar.aUpgrades[arrPerkTree[I]] -= 1;
        }
    }

}

function VanRandPerks()
{
	local int I, J, K, Perk, iClass, Perk1, Perk2;
	local array<int> PerkTree;
	local XGStrategySoldier kSold;
	local bool hasPerk;

	if(m_kSold != none)
		kSold = m_kSold;
	else
	{
		kSold = SOLDIER();
		m_kSold = kSold;
	}

	`logde("VanRandPerks");
	`logde(`ShowVar(kSold));

	if(FindSoldierInStorage(, kSold) == -1)
	{
		CreateSoldierStor(kSold);
	}

	FlushRandomTree(kSold);

	for(I=1; I<8; I++)
	{
		for(J=0; J<3; J++)
		{
			hasPerk = false;
			PerkTree = NewRandomTree(kSold, -1);

			if(kSold.GetClass() == 6 || I > 1)
				iClass = kSold.m_iEnergy;
			else
				iClass = kSold.GetClass();
			`logde(`ShowVar(iClass));

			Perk = kSold.PERKS().GetPerkInTree( iClass, I, J);
			`logde(`ShowVar(Perk));

			for(K=0; K<MergePerk1.Length; K++)
			{
				Perk1 = SearchPerks(MergePerk1[K]);
				Perk2 = SearchPerks(MergePerk2[K]);

				if( (MergePerkClass[K] == kSold.m_iEnergy || MergePerkClass[K] == kSold.GetClass()) && (Perk == Perk2) && ( (PerkTree.Find(Perk1) != -1) || (kSold.HasPerk(Perk1)) ))
				{
					hasPerk = true;
				}
			}
			if(kSold.HasPerk(Perk))
			{
				hasPerk = true;
			}

			if(!kSold.PERKS().IsFixedPerk(Perk) || hasPerk)
			{
				perk = 0;
				while(!VanRandPerkCheck(Perk))
				{
					Perk = kSold.PERKS().GetRandomPerk();
				}
			}

			`logde(`ShowVar(Perk));
			addPerkToTree(kSold, Perk);
		}
	}
	CreatePerkStats();
}

function bool VanRandPerkCheck(int Perk)
{
	local int I, Perk1, Perk2;
	local array<int> tree; 

	if(Perk == 0)
		return false;

	tree = NewRandomTree(m_kSold, -1);

	if(tree.Find(Perk) != -1)
		return false;

	switch(Perk)
	{
		case 23:
			return tree.Find(54) == -1;
		case 54:
			return tree.Find(23) == -1;
		case 255:
			if(m_kSold.m_kChar.eClass == 6)
				return false;
			if(m_kSold.m_kChar.eClass == 2)
				return false;
			break;
		case 26:
			if(m_kSold.m_kChar.eClass == 1)
				return false;
			break;
		default:
			break;
	}

	for(I=0; I<MergePerk1.Length; I++)
	{
		Perk1 = SearchPerks(MergePerk1[I]);
		Perk2 = SearchPerks(MergePerk2[I]);

		if( (MergePerkClass[I] == m_kSold.m_iEnergy || MergePerkClass[I] == m_kSold.GetClass()) && (Perk == Perk2) && ( (tree.Find(Perk1) != -1) || (m_kSold.HasPerk(Perk1)) ))
		{
			return false;
		}
	}
	
	return true;
}

function GetVanMECPerks()
{
	local int I, J, Perk;
	local XGStrategySoldier kSold;

	if(m_kSold != none)
		kSold = m_kSold;
	else
		kSold = SOLDIER();

	if(FindSoldierInStorage(, kSold) == -1)
	{
		CreateSoldierStor(kSold);
	}

	FlushRandomTree(kSold);

	for(I=1; I<8; I++)
	{
		for(J=0; J<3; J++)
		{
			Perk = kSold.PERKS().GetPerkInTree(kSold.m_iEnergy, I, J);

			if(kSold.HasPerk(Perk))
				Perk = 0;
			
			addPerkToTree(kSold, Perk);
		}
	}
}

function GetRandomPerks()
{

	local string Perk;
	local array<string> SemiSPerks;
	local int I, J, K, L, opt, iClass;
	local bool isMEC, bStatic, bSPFound;
	local XGStrategySoldier kSold;
	local array<TSemiSPerkPos> SemiSPerkPoss;
	local TSemiSPerkPos SemiSPerkPos;

	if(m_kSold != none)
	{
		kSold = m_kSold;
	}
	else
	{
		kSold = SOLDIER();
	}

	if(FindSoldierInStorage(, kSold) == -1)
	{
		CreateSoldierStor(kSold);
	}

	FlushRandomTree(kSold);
	
	iClass = kSold.m_iEnergy;
	
	isMEC = kSold.GetClass() == 6;
	
	for(I=0; I<SemiStaticPerks.Length; I++)
	{
		if(SemiStaticPerks[I].iClass == iClass)
		{
			SemiSPerkPos.Poss = SemiSParse(I);
			SemiSPerkPos.perk = SemiStaticPerks[I].SPerk;
			
			SemiSPerkPoss.AddItem(SemiSPerkPos);
		}
	}
	
	
	for(I=1; I<8; I++)
	{
		for(J=0; J<3; J++)
		{
			bSPFound = false;
			
			for(K=0; K<StaticPerks.Length; K++)
			{
				if( (iClass == StaticPerks[K].iClass) && (I == (StaticPerks[K].Pos + 2) / 3) )
				{
					opt = 0;
					if((StaticPerks[K].Pos + 2) % 3 == 0)
					{
						opt = 2;
					}
					if((StaticPerks[K].Pos + 2) % 3 == 1)
					{
						opt = 1;
					}
					
					if(J == opt)
					{
						Perk = StaticPerks[K].SPerk;
						bStatic = true;
						break;
					}
				}
			}
			
			if(!bStatic)
			{
				for(K=0; K<SemiSPerkPoss.Length; K++)
				{
					SemiSPerks = GetSemiSPerks(I, J, SemiSPerkPoss[K]);
					
					for(L=0; !bSPFound && L<SemiSPerks.Length; L++)
					{
						Perk = SemiSPerks[L];
						bSPFound = CheckPerkRules(Perk);
					}
					
				}
				
				if(I == 1)
				{
					Perk = String(EPerkType(0));
				}
				else if(!bSPFound)
				{
					while(!CheckPerkRules(Perk))
					{
						Perk = GetPerkFromPool();
					}
				}
			}
			
			
			addPerkToTree(kSold, SearchPerks(Perk));
			//kSold.m_arrRandomPerks.AddItem(SearchPerks(Perk));

		}
	}
	CreatePerkStats();
	

}

function array<int> SemiSParse(int SemiSPos)
{
	local int I, J, SemiSOpt, posRange;
	local array<int> SemiSPPos;
	local array<string> arrStr1, arrStr2;

	arrStr1 = SplitString(SemiStaticPerks[SemiSPos].Pos);
	
	for(I=0; I<arrStr1.Length; I++)
	{
		posRange = 0;
		arrStr2.Length = 0;

		if(int(arrStr1[I]) != 0)
			SemiSOpt = int(arrStr1[I]);
				
		if(InStr(arrStr1[I], "-") != -1)
		{
			arrStr2 = SplitString(arrStr1[I], "-");
			posRange = int(arrStr2[1]);
		}
				
		for(J= arrStr2.Length!=0 ? int(arrStr2[0]) : 0; J<=posRange; J++)
		{
			if(J != 0)
				SemiSOpt = J;

			SemiSOpt -= 1;
				
			if(SemiSOpt == -2)
				SemiSOpt = (Rand(18) + 3);
			
			if(SemiSOpt > 2)
				SemiSPPos.AddItem(SemiSOpt);			
		}
	}
	
	return SemiSPPos;
}

function array<string> GetSemiSPerks(int Rank, int Option, TSemiSPerkPos SemiSPerkPos)
{
	local int I, opt;
	local array<string> SemiSPerks;

	for(I=0; I<SemiSPerkPos.Poss.Length; I++)
	{
		if(Rank == (SemiSPerkPos.Poss[I] + 3) / 3)
		{
			opt = 0;
			if(((SemiSPerkPos.Poss[I] + 3) % 3) == 0)
				opt = 2;
			if(((SemiSPerkPos.Poss[I] + 3) % 3) == 1)
				opt = 1;
			
			if(opt == Option)
				SemiSPerks.AddItem(SemiSPerkPos.perk);
		}
	}
	return SemiSPerks;
}

function string GetPerkFromPool()
{

	local string perk;
	local int iClass;
	local bool isMEC;
	local array<string> arrPool;
	local XGStrategySoldier kSold;

	if(m_kSold != none)
	{
		kSold = m_kSold;
	}
	else
	{
		kSold = SOLDIER();
	}

	iClass = kSold.m_iEnergy;
	isMEC = kSold.GetClass() == 6;


	if(PoolPrioity == 2)
	{
		switch(iClass)
		{
			case 11:
				arrPool = NewPerkPool(SniperPerks, isMEC);
				Perk = arrPool[Rand(arrPool.Length)];
				break;
			case 21:
				arrPool = NewPerkPool(ScoutPerks, isMEC);
				Perk = arrPool[Rand(arrPool.Length)];
				break;
			case 12:
				arrPool = NewPerkPool(RocketeerPerks, isMEC);
				Perk = arrPool[Rand(arrPool.Length)];
				break;
			case 22:
				arrPool = NewPerkPool(GunnerPerks, isMEC);
				Perk = arrPool[Rand(arrPool.Length)];
				break;
			case 13:
				arrPool = NewPerkPool(MedicPerks, isMEC);
				Perk = arrPool[Rand(arrPool.Length)];
				break;
			case 23:
				arrPool = NewPerkPool(EngineerPerks, isMEC);
				Perk = arrPool[Rand(arrPool.Length)];
				break;
			case 14:
				arrPool = NewPerkPool(AssaultPerks, isMEC);
				Perk = arrPool[Rand(arrPool.Length)];
				break;
			case 24:
				arrPool = NewPerkPool(InfantryPerks, isMEC);
				Perk = arrPool[Rand(arrPool.Length)];
				break;
			case 31:
				arrPool = NewPerkPool(JaegerPerks, isMEC);
				Perk = arrPool[Rand(arrPool.Length)];
				break;
			case 41:
				arrPool = NewPerkPool(PathfinderPerks, isMEC);
				Perk = arrPool[Rand(arrPool.Length)];
				break;
			case 32:
				arrPool = NewPerkPool(ArcherPerks, isMEC);
				Perk = arrPool[Rand(arrPool.Length)];
				break;
			case 42:
				arrPool = NewPerkPool(GoliathPerks, isMEC);
				Perk = arrPool[Rand(arrPool.Length)];
				break;
			case 33:
				arrPool = NewPerkPool(GuardianPerks, isMEC);
				Perk = arrPool[Rand(arrPool.Length)];
				break;
			case 43:
				arrPool = NewPerkPool(ShogunPerks, isMEC);
				Perk = arrPool[Rand(arrPool.Length)];
				break;
			case 34:
				arrPool = NewPerkPool(MarauderPerks, isMEC);
				Perk = arrPool[Rand(arrPool.Length)];
				break;
			case 44:
				arrPool = NewPerkPool(ValkyriePerks, isMEC);
				Perk = arrPool[Rand(arrPool.Length)];
				break;
			default:
				break;
		}
	
	}
	else 
	{
		if(PoolPrioity == 1)
		{
			perk = 	AllSoldierPerks[Rand(AllSoldierPerks.Length)];
			if(!CheckPerkRules(perk))
			{
				if(isMEC)
				{
					perk = AllMECPerks[Rand(AllMECPerks.Length)];
				}
				else
				{
					perk = AllBioPerks[Rand(AllBioPerks.Length)];
				}
			}
		}

		if(!CheckPerkRules(perk) || PoolPrioity == 0)
		{
			switch(iClass)
			{
				case 11:
					Perk = SniperPerks[Rand(SniperPerks.Length)];
					break;
				case 21:
					Perk = ScoutPerks[Rand(ScoutPerks.Length)];
					break;
				case 12:
					Perk = RocketeerPerks[Rand(RocketeerPerks.Length)];
					break;
				case 22:
					Perk = GunnerPerks[Rand(GunnerPerks.Length)];
					break;
				case 13:
					Perk = MedicPerks[Rand(MedicPerks.Length)];
					break;
				case 23:
					Perk = EngineerPerks[Rand(EngineerPerks.Length)];
					break;
				case 14:
					Perk = AssaultPerks[Rand(AssaultPerks.Length)];
					break;
				case 24:
					Perk = InfantryPerks[Rand(InfantryPerks.Length)];
					break;
				case 31:
					Perk = JaegerPerks[Rand(JaegerPerks.Length)];
					break;
				case 41:
					Perk = PathfinderPerks[Rand(PathfinderPerks.Length)];
					break;
				case 32:
					Perk = ArcherPerks[Rand(ArcherPerks.Length)];
					break;
				case 42:
					Perk = GoliathPerks[Rand(GoliathPerks.Length)];
					break;
				case 33:
					Perk = GuardianPerks[Rand(GuardianPerks.Length)];
					break;
				case 43:
					Perk = ShogunPerks[Rand(ShogunPerks.Length)];
					break;
				case 34:
					Perk = MarauderPerks[Rand(MarauderPerks.Length)];
					break;
				case 44:
					Perk = ValkyriePerks[Rand(ValkyriePerks.Length)];
					break;
				default:
					break;
			}
		
		}
	
		if(PoolPrioity == 0)
		{
			if(!CheckPerkRules(perk))
			{
				if(isMEC)
				{
					perk = AllMECPerks[Rand(AllMECPerks.Length)];
				}
				else
				{
					Perk = AllBioPerks[Rand(AllBioPerks.Length)];
				}
				if(!CheckPerkRules(Perk))
				{
					Perk = AllSoldierPerks[Rand(AllSoldierPerks.Length)];
				}
			}
		}	
	}
	
	Return Perk;		

}

function bool CheckPerkRules(string Perk)
{
	local int I, J, iPerk, Perk1, Perk2, iClass;
	local bool bFound;
	local array<int> PerkTree;
	local XGStrategySoldier kSold;
	
	`ifdebug local bool debuglog; `endif

	`logde("CheckPerkRules start, Perk= \"" $ Perk $ "\"");

	if(m_kSold != none)
	{
		kSold = m_kSold;
	}
	else
	{
		kSold = SOLDIER();
	}

	`logde("kSold= " $ string(kSold));

	iPerk = SearchPerks(Perk);

	`logde("iPerk= " $ string(iPerk));

	iClass = kSold.m_iEnergy;

	`logde("iClass= " $ string(iClass));

	PerkTree = NewRandomTree(kSold, -1);

	if(Perk == string(EPerkType(0)) || iPerk == 0 || Perk == "")
	{
		return false;
	}
	`logde("not 0");

	if(iPerk > 255)
	{
		return false;
	}
	`logde("not overbyte");

	if(PerkTree.Find(iPerk) != -1)
	{
		return false;
	}
	if(kSold.HasPerk(iPerk))
	{
		return false;
	}
	`logde("not already used");

	for(I=0; I<IncompatiblePerks1.Length; I++)
	{
		Perk1 = SearchPerks(IncompatiblePerks1[I]);
		Perk2 = SearchPerks(IncompatiblePerks2[I]);

		switch(Perk)
		{
			case IncompatiblePerks1[I]:
				if(PerkTree.Find(Perk2) != -1 || kSold.HasPerk(Perk2))
				{
					`logde("return false in Incompat perks");
					return false;
				}
				break;
			case IncompatiblePerks2[I]:
				if(PerkTree.Find(Perk1) != -1 || kSold.HasPerk(Perk1))
				{
					`logde("return false in Incompat perks");
					return false;
				}
				break;
			default:
				break;
		}
	}

	for(I=0; I<ChainPerks1.Length; I++)
	{
		Perk1 = SearchPerks(ChainPerks1[I]);
		Perk2 = SearchPerks(ChainPerks2[I]);

		`ifdebug if(Perk == ChainPerks1[I] || Perk == ChainPerks2[I]) debuglog = true; else debuglog = false; `endif

		`logde("chainperks:", debuglog);

		switch(PerkTree.Length % 3)
		{
			case 1:
				`logde("case1",debuglog);
				`logde(`showvar(Perk == ChainPerks1[I]),debuglog);
				`logde(`showvar(EPerkType(PerkTree[PerkTree.Length-1])),debuglog && Perk == ChainPerks1[I]);
				`logde(`showvar(Perk2 == PerkTree[PerkTree.Length-1]),debuglog && Perk == ChainPerks1[I]);
				if(Perk == ChainPerks1[I] && Perk2 == PerkTree[PerkTree.Length-1])
				{
					`logde("return false in chainperks");
					return false;
				}
				`logde(`showvar(Perk == ChainPerks2[I]),debuglog);
				`logde(`showvar(EPerkType(PerkTree[PerkTree.Length-1])),debuglog && Perk == ChainPerks2[I]);
				`logde(`showvar(Perk1 == PerkTree[PerkTree.Length-1]),debuglog && Perk == ChainPerks2[I]);
				if(Perk == ChainPerks2[I] && Perk1 == PerkTree[PerkTree.Length-1])
				{
					`logde("return false in chainperks");
					return false;
				}
				break;
			case 2:
				`logde("case2",debuglog);
				`logde(`showvar(Perk == ChainPerks1[I]),debuglog);
				`logde(`showvar(EPerkType(PerkTree[PerkTree.Length-1])),debuglog && Perk == ChainPerks1[I]);
				`logde(`showvar(Perk2 == PerkTree[PerkTree.Length-1]),debuglog && Perk == ChainPerks1[I]);
				`logde(`showvar(EPerkType(PerkTree[PerkTree.Length-2])),debuglog && Perk == ChainPerks1[I]);
				`logde(`showvar(Perk2 == PerkTree[PerkTree.Length-2]),debuglog && Perk == ChainPerks1[I]);
				`logde("total:'" $ string(Perk2 == PerkTree[PerkTree.Length-1] || Perk2 == PerkTree[PerkTree.Length-2]) $ "'", debuglog && Perk == ChainPerks1[I]);
				if(Perk == ChainPerks1[I] && ( Perk2 == PerkTree[PerkTree.Length-1] || Perk2 == PerkTree[PerkTree.Length-2] ))
				{
					`logde("return false in chainperks");
					return false;
				}
				`logde(`showvar(Perk == ChainPerks2[I]),debuglog);
				`logde(`showvar(EPerkType(PerkTree[PerkTree.Length-1])),debuglog && Perk == ChainPerks2[I]);
				`logde(`showvar(Perk1 == PerkTree[PerkTree.Length-1]),debuglog && Perk == ChainPerks2[I]);
				`logde(`showvar(EPerkType(PerkTree[PerkTree.Length-2])),debuglog && Perk == ChainPerks2[I]);
				`logde(`showvar(Perk1 == PerkTree[PerkTree.Length-2]),debuglog && Perk == ChainPerks2[I]);
				`logde("total:'" $ string(Perk1 == PerkTree[PerkTree.Length-1] || Perk1 == PerkTree[PerkTree.Length-2]) $ "'", debuglog && Perk == ChainPerks1[I]);
				if(Perk == ChainPerks2[I] && ( Perk1 == PerkTree[PerkTree.Length-1] || Perk1 == PerkTree[PerkTree.Length-2] ))
				{
					`logde("return false in chainperks");
					return false;
				}
				break;
			default:
				break;
		}
	}


	for(I=0; I<StaticPerks.Length; I++)
	{
		if(kSold.m_iEnergy == StaticPerks[I].iClass && Perk == StaticPerks[I].SPerk)
		{
			`logde("return false in staticperks");
			return false;
		}
	}

	for(I=0; I<PerkChance.Length; I++)
	{
		`ifdebug
			if( (PerkChance[I].PerkC == Perk && PerkChance[I].iClass == iClass) && (
				PerkChance[I].Rank == -1 || PerkChance[I].Rank == (PerkTree.Length + 3) / 3) )
			{
				StrValue2("Check PerkChance");
			}
		`endif

		if( (PerkChance[I].PerkC == string(0) || PerkChance[I].PerkC == Perk) && (
			(PerkChance[I].iClass == -1 || PerkChance[I].iClass == iClass) ) && (
			(PerkChance[I].Rank == -1 || PerkChance[I].Rank == (PerkTree.Length + 3) / 3) ) && (
			!PercentRoll(PerkChance[I].chance) ))
		{
			`logde("return false in perkchance");
			return false;
		}
	}

	for(I=0; I<ChoicePerks1.Length; I++)
	{
		Perk1 = SearchPerks(ChoicePerks1[I]);
		Perk2 = SearchPerks(ChoicePerks2[I]);

		if(Perk == ChoicePerks1[I] && PerkTree.Find(Perk2) != -1)
		{
			switch(PerkTree.Length % 3)
			{
				case 0:
					`logde("return false in choiceperks");
					return false;
					break;
				case 1:
					if(Perk2 != PerkTree[PerkTree.Length-1])
					{
						`logde("return false in choiceperks");
						return false;
					}
					break;
				case 2:
					if(Perk2 != PerkTree[PerkTree.Length-1] && Perk2 != PerkTree[PerkTree.Length-2])
					{
						`logde("return false in choiceperks");
						return false;
					}
					break;
				default:
					break;
			}
		}
		if(Perk == ChoicePerks2[I] && PerkTree.Find(Perk1) != -1)
		{
			switch(PerkTree.Length % 3)
			{
				case 0:
					`logde("return false in choiceperks");
					return false;
					break;
				case 1:
					if(Perk1 != PerkTree[PerkTree.Length-1])
					{
						`logde("return false in choiceperks");
						return false;
					}
					break;
				case 2:
					if(Perk1 != PerkTree[PerkTree.Length-1] && Perk1 != PerkTree[PerkTree.Length-2])
					{
						`logde("return false in choiceperks");
						return false;
					}
					break;
				default:
					break;
			}
		}

	}

	for(I=0; I<RequiredPerk1.Length; I++)
	{
		Perk1 = SearchPerks(RequiredPerk1[I]);
		bFound = false;
		if( (Perk == RequiredPerk1[I]) && ( (RequiredPerkClass[I] == -1) || (RequiredPerkClass[I] == iClass) ) ) 
		{
			`logde("RequiredPerk:" @ `Showvar(RequiredPerk1[I]));

			for(J=0; J<RequiredPerk2[I].Perk.Length; J++)
			{
				Perk2 = SearchPerks(RequiredPerk2[I].Perk[J]);

				`logde(`showvar(SOLDIER().HasPerk(Perk2)));
				`logde(`showvar(PerkTree.Find(Perk2) != -1));
				`logde(`showvar(( ((PerkTree.Find(Perk2) + 3) / 3) != ((PerkTree.Length + 3) / 3) )));
				`logde("total:'" $ string(SOLDIER().HasPerk(Perk2) || ( PerkTree.Find(Perk2) != -1 && ((PerkTree.Find(Perk2) + 3) / 3) != ((PerkTree.Length + 3) / 3) ) ) $ "'");

				if(SOLDIER().HasPerk(Perk2) || ( PerkTree.Find(Perk2) != -1 && ((PerkTree.Find(Perk2) + 3) / 3) != ((PerkTree.Length + 3) / 3) ) )
				{
					bFound = true;
					break;
				}

			}

			if(!bFound)
			{
				`logde("return false in requiredperks");
				return false;
			}
		}
	}

	for(I=0; I<MergePerk1.Length; I++)
	{
		Perk1 = SearchPerks(MergePerk1[I]);
		Perk2 = SearchPerks(MergePerk2[I]);

		if( (MergePerkClass[I] == iClass) && (Perk == MergePerk2[I]) && ( (PerkTree.Find(Perk1) != -1) || (kSold.HasPerk(Perk1)) ))
		{
			`logde("return false in mergeperks");
			return false;
		}
	}

	`logde("return true");
	return true;

}

function int SearchPerks(string sPerk)
{

	local TAliasArr lAlias;

	if(arrPerk.Find(sPerk) != -1)
	{
		return arrPerk.Find(sPerk);
	}
	else
	{
		foreach arrAlias(lAlias)
		{
			if(lAlias.Alias.Find(sPerk) != -1)
			{
				return lAlias.Alias.Find(sPerk);
			}
		}
	}

	return 0;
}

function array<string> NewPerkPool(array<string> OldPerkPool, bool isMEC)
{
	local array<string> NewPerkPool, AppendedPool;
	local int i, j;

	for(i=0; i<OldPerkPool.Length; i++)
	{
		AppendedPool.AddItem(OldPerkPool[i]);
	}

	for(i=0; i<AllSoldierPerks.Length; i++)
	{
		AppendedPool.AddItem(AllSoldierPerks[i]);
	}

	if(isMEC)
	{
		for(i=0; i<AllMECPerks.Length; i++)
		{
			AppendedPool.AddItem(AllMECPerks[i]);
		}
	}
	else
	{
		for(i=0; i<AllBioPerks.Length; i++)
		{
			AppendedPool.AddItem(AllBioPerks[i]);
		}
	}

	NewPerkPool.Add(AppendedPool.Length);
	for(i=0; i<AppendedPool.Length; i++)
	{
		j = Rand(AppendedPool.Length);
		NewPerkPool.InsertItem(j, AppendedPool[i]);
		NewPerkPool.Remove(NewPerkPool.Find(""), 1);
	}

	if(NewPerkPool.Find("") != -1)
		NewPerkPool.RemoveItem("");

	return NewPerkPool;

}

function CreatePerkStats()
{

	local int opt, PerkS, iClass, Pos, mPerk, I, J;	
	local string sPerk;
	local bool isRank1, bFound;
	local TPerkStats lPerkS;
	local array<int> PerkTree;
	local XGStrategySoldier kSold;
	local TStatStorage Stats;

	if(m_kSold != none)
	{
		kSold = m_kSold;
	}
	else
	{
		kSold = SOLDIER();
	}

	m_kRPCheckpoint.arrSoldierStorage[FindSoldierInStorage(kSold.m_kSoldier.iID)].isNewType = true;

	FlushStatStorage(kSold);

	PerkTree = NewRandomTree(kSold, -1);

	for(Pos=0; Pos<21; Pos++)
	{
		opt = ((Pos % 3) + 1);
		if(opt == 1)
		{
			opt = 3;
		}
		else if(opt == 3)
		{
			opt = 1;
		}

		isRank1 = ((pos + 3) / 3) == 1;

		if(isRank1 && kSold.GetClass() != 6)
		{
			iClass = kSold.GetClass();
		}
		else
		{
			iClass = kSold.m_iEnergy;
		}

		foreach MergePerk1(sPerk, I)
		{
			mPerk = 0;
			if(SearchPerks(sPerk) == PerkTree[pos])
			{
				if(MergePerkClass[I] == -1 || MergePerkClass[I] == iClass)
				{
					mPerk = SearchPerks(MergePerk2[I]);
					break;
				}
			}
		}
		
		bFound = false;

		foreach PerkStats(lPerkS, J)
		{

			if(lPerkS.Stats > 0)
			{
				if(lPerkS.Stats / 100 == 1)
				{
					lPerkS.mob = 1;
				}
				if(lPerkS.Stats / 100 == 2)
				{
					lPerkS.mob = -1;
				}
				lPerkS.aim = (lPerkS.Stats % 100) / 10;
				lPerkS.will = lPerkS.Stats % 10;
			}

			PerkS = -1;
			if( (lPerkS.Perk != "0") && 
				( (lPerkS.Rank == (Pos + 3) / 3) || (lPerkS.Rank == -1) ) && 
				( (lPerkS.iClass == -1) || (lPerkS.iClass == iClass) ) )
			{
				PerkS = SearchPerks(lPerkS.Perk);
			}

			if(!isRank1)
			{
				if( (lPerkS.Option == opt) && 
					(isRank1) &&
					(lPerkS.iClass == kSold.GetClass()) &&
					(lPerkS.Rank == 1) ) 
				{
					bFound = true;
					Stats = MakePerkStats(lPerkS.hp, lPerkS.aim, lPerkS.def, lPerkS.mob, lPerkS.will, mPerk);
					addPerkStats(kSold, Stats);
					break;
				}
				else if( PerkS > -1 && PerkTree[pos] == PerkS)
				{
					bFound = true;
					Stats = MakePerkStats(lPerkS.hp, lPerkS.aim, lPerkS.def, lPerkS.mob, lPerkS.will, mPerk);
					addPerkStats(kSold, Stats);
					break;
				}
			}
		}
		
		if(!bFound || isRank1)
		{
			Stats = MakePerkStats(0, 0, 0, 0, 0, mPerk);
			addPerkStats(kSold, Stats);
		}
	}

}

function NewPerkStats(int Pos)
{
	
	local TStatStorage PStats;
	local XGStrategySoldier kSold;

	if(m_kSold != none)
	{
		kSold = m_kSold;
	}
	else
	{
		kSold = SOLDIER();
	}


	PStats = GetPerkStats(kSold, Pos);
	`logde("NewPerkStats");
	`logde(`ShowVar(PStats.HP) $ ", " $ `ShowVar(PStats.aim) $ ", " $ `ShowVar(PStats.def) $ ", " $ `ShowVar(PStats.will) $ ", " $ `ShowVar(PStats.mob));

	if(PStats.HP * -1 >= kSold.GetMaxStat(0))
		PStats.HP = (kSold.GetMaxStat(0) - 1) * -1;

	if(kSold.GetCurrentStat(0) == 1 && PStats.HP < 0)
		kSold.Heal(PStats.HP * -1);

	kSold.m_kChar.aStats[eStat_HP] += PStats.HP;
	kSold.m_kChar.aStats[eStat_Offense] += PStats.aim;
	kSold.m_kChar.aStats[eStat_Defense] += PStats.def;
	kSold.m_kChar.aStats[eStat_Will] += PStats.will;
	kSold.m_kChar.aStats[eStat_Mobility] += PStats.mob;




}

function array<int> OldPerkTree(XGStrategySoldier Sold)
{

	local int I;
	local array<int> arrInts;

	if(Sold.m_arrRandomPerks.Length > 0)
	{
		for(I=0; I<Sold.m_arrRandomPerks.Length; I++)
		{
			arrInts.AddItem(Sold.m_arrRandomPerks[I]);
		}
	}
	else
	{
		arrInts.Length = 22;
	}
	return arrInts;
}

function OldPerkStats(int Pos, optional bool query)
{
	
	local int I, opt, will, hp, mob, def, aim, perk, hpmob, PerkS, iClass;
	local XComPerkManager kPerkMan;
	local string mPerk;
	local bool isRank1, bFound;
	local TPerkStats lPerkS;
	local array<int> PerkTree, querystats;
	local XGStrategySoldier kSold;

	if(m_kSold != none)
	{
		kSold = m_kSold;
	}
	else
	{
		kSold = SOLDIER();
	}

	PerkTree = OldPerkTree(kSold);

	kPerkMan = kSold.PERKS();

	/** 
	for(I=0; I<kSold.m_arrRandomPerks.Length; I++)
	{
		`logde("RandomPerks=" @ string(kSold.m_arrRandomPerks[I]));
	}
	*/

	isRank1 = ((pos + 3) / 3) == 1;
	
	/**   
	foreach MergePerk1(mPerk, I)
	{
		perk = SearchPerks(mPerk);

		if( (isRank1 && kPerkMan.GetPerkInTree(SOLDIER().GetClass(), 1, (pos - 1)) == perk) || ( (MergePerkClass[I] == -1 || MergePerkClass[I] == kSold.m_iEnergy) && kSold.m_arrRandomPerks[Pos-1] == perk ) )
		{
			kSold.m_arrRandomPerks[2] = 100;
			kSold.m_arrRandomPerks[21] = EPerkType(SearchPerks(MergePerk2[I]));	
		}
		else
		{
			kSold.m_arrRandomPerks[2] = 0;
			kSold.m_arrRandomPerks[21] = 0;
		}
	}
	*/

	opt = ((Pos % 3) + 1);
	if(opt == 1)
	{
		opt = 3;
	}
	else if(opt == 3)
	{
		opt = 1;
	}

	if(isRank1 && kSold.GetClass() != 6)
	{
		iClass = kSold.GetClass();
	}
	else
	{
		iClass = kSold.m_iEnergy;
	}

	foreach PerkStats(lPerkS)
	{
		bFound = false;

		if( (lPerkS.Option == opt) &&
			(isRank1) && 
			(lPerkS.iClass == kSold.GetClass()) && 
			(lPerkS.Rank == 1) )
		{
			bFound = true;
			break;
		}
		else if( (lPerkS.Perk != "0") && 
				( (lPerkS.Rank == (Pos + 3) / 3) || (lPerkS.Rank == -1) ) && 
				( (lPerkS.iClass == -1) || (lPerkS.iClass == iClass) ) )
		{
			PerkS = SearchPerks(lPerkS.Perk);

			if(PerkTree[pos] == PerkS)
			{
				bFound = true;
				break;
			}

		}
	}

	if(bFound)
	{
		mob = 0;
		will = 0;
		hp = 0;
		def = 0;
		aim = 0;
		hpmob = 0;

		if(lPerkS.Stats > 0)
		{
			if(lPerkS.Stats / 100 == 1)
			{
				mob = 1;
			}
			if(lPerkS.Stats / 100 == 2)
			{
				mob = -1;
			}
			aim = (lPerkS.Stats % 100) / 10;
			will = lPerkS.Stats % 10;
		}
		else
		{
				aim = lPerkS.aim;

				will = lPerkS.will;

				mob = lPerkS.mob;
		}
			hp = lPerkS.hp;

			def = lPerkS.def;

	}


	if(query)
	{
		querystats.AddItem(aim);
		querystats.AddItem(will);
		querystats.AddItem(hp);
		querystats.AddItem(mob);
		querystats.AddItem(def);
				
		arrInts(querystats, true);
	}
	else
		OldAddstats(aim, will, hp, mob, def); 
	


}

function OldAddstats(int aim, int will, int hp, int mob, int def)
{

	local XGStrategySoldier kSold;

	if(m_kSold != none)
	{
		kSold = m_kSold;
	}
	else
	{
		kSold = SOLDIER();
	}

	`logde(`ShowVar(hp) $ ", " $ `ShowVar(aim) $ ", " $ `ShowVar(def) $ ", " $ `ShowVar(will) $ ", " $ `ShowVar(mob));

	kSold.m_kChar.aStats[eStat_HP] += hp;
	kSold.m_kChar.aStats[eStat_Offense] += aim;
	kSold.m_kChar.aStats[eStat_Defense] += def;
	kSold.m_kChar.aStats[eStat_Will] += will;
	kSold.m_kChar.aStats[eStat_Mobility] += mob;
}

function int FindSoldierInStorage(optional int SoldierID = -1, optional XGStrategySoldier Sold)
{
	
	local TSoldierStorage SoldStor;
	local int I;

	if(SoldierID == -1 && Sold != none)
	{
		SoldierID = Sold.m_kSoldier.iID;
	}

	if(!(SoldierID > -1))
	{
		return -1;
	}


	if(m_kRPCheckpoint.arrSoldierStorage.Length > 0)
	{
		foreach m_kRPCheckpoint.arrSoldierStorage(SoldStor, I)
		{
			if(SoldStor.SoldierID == SoldierID)
			{
				return I;
			}
		}
	}

	return -1;
}

function int CreateSoldierStor(XGStrategySoldier Soldier)
{
	local int pos;

	pos = m_kRPCheckpoint.arrSoldierStorage.Length;

	m_kRPCheckpoint.arrSoldierStorage.Add(1);
	m_kRPCheckpoint.arrSoldierStorage[pos].SoldierID = Soldier.m_kSoldier.iID;

	return pos;
}

function bool isSoldierNewType(XGStrategySoldier Soldier)
{
	if(m_kRPCheckpoint.arrSoldierStorage.Length > 0)
	{
		if(FindSoldierInStorage(Soldier.m_kSoldier.iID) != -1)
			return m_kRPCheckpoint.arrSoldierStorage[FindSoldierInStorage(Soldier.m_kSoldier.iID)].isNewType;
	}

	return false;
}

function array<int> NewRandomTree(XGStrategySoldier kSold, int position, optional int value)
{

	local array<int> arrInts;

	if(position == -2)
	{
		arrInts[0] = m_kRPCheckpoint.arrSoldierStorage[FindSoldierInStorage(kSold.m_kSoldier.iID)].RandomTree.Length;
		return arrInts;
	}
	else if(position == -1)
	{
		return m_kRPCheckpoint.arrSoldierStorage[FindSoldierInStorage(kSold.m_kSoldier.iID)].RandomTree;
	}
	else if(value != 0)
	{
		m_kRPCheckpoint.arrSoldierStorage[FindSoldierInStorage(kSold.m_kSoldier.iID)].RandomTree[position] = value;
		return arrInts;
	}
	else
	{
		arrInts[0] = m_kRPCheckpoint.arrSoldierStorage[FindSoldierInStorage(kSold.m_kSoldier.iID)].RandomTree[position];
		return arrInts;
	}
}

function FlushRandomTree(XGStrategySoldier kSold)
{
	if(kSold != none)
		m_kRPCheckpoint.arrSoldierStorage[FindSoldierInStorage(kSold.m_kSoldier.iID)].RandomTree.Length = 0;
}

function FlushStatStorage(XGStrategySoldier kSold)
{
	if(kSold != none)
		m_kRPCheckpoint.arrSoldierStorage[FindSoldierInStorage(kSold.m_kSoldier.iID)].StatStorage.Length = 0;
}

function TStatStorage GetPerkStats(XGStrategySoldier kSold, int index)
{
	return m_kRPCheckpoint.arrSoldierStorage[FindSoldierInStorage(kSold.m_kSoldier.iID)].StatStorage[index];
}

function TStatStorage MakePerkStats(int HP, int aim, int def, int mob, int will, int mPerk)
{
	
	local TStatStorage stats;

	stats.HP = HP;
	stats.aim = aim;
	stats.def = def;
	stats.mob = mob;
	stats.will = will;
	stats.perk = mPerk;

	return stats;
}

function addPerkStats(XGStrategySoldier kSold, TStatStorage Stats)
{
	m_kRPCheckpoint.arrSoldierStorage[FindSoldierInStorage(kSold.m_kSoldier.iID)].StatStorage.AddItem(Stats);
}

function addPerkToTree(XGStrategySoldier kSold, int perk)
{
	m_kRPCheckpoint.arrSoldierStorage[FindSoldierInStorage(kSold.m_kSoldier.iID)].RandomTree.AddItem(perk);
}

function PerkMerge(int Perk)
{
	local XGStrategySoldier kSold;
	
	if(m_kSold != none)
	{
		kSold = m_kSold;
	}
	else
	{
		kSold = SOLDIER();
	}

	kSold.GivePerk(GetMergedPerk(Perk));
}

function int GetMergedPerk(int Perk)
{
	local int I, Perk1, Perk2;
	local array<int> PerkTree;
	local string mPerk;
	local XGStrategySoldier kSold;

	if(m_kSold != none)
	{
		kSold = m_kSold;
	}
	else
	{
		kSold = SOLDIER();
	}

	`log(`ShowVar(kSold),, 'GetMergedPerk');

	`Log(`ShowVar(Perk) @ `ShowVar(kSold.HasPerk(Perk), HasPerk),, 'GetMergedPerk');

	`Log(`ShowVar(IsSoldierNewType(kSold), IsSoldierNewType) @ `ShowVar(SOLDIERUI().GetAbilityTreeBranch() != 1, NotRank1),, 'GetMergedPerk');

	if(kSold.HasPerk(Perk))
	{
		if(IsSoldierNewType(kSold) && SOLDIERUI().GetAbilityTreeBranch() != 1)
		{
			perktree = NewRandomTree(kSold, -1);

			for(I=0; I<perktree.Length; I++)
			{

				`Log(`ShowVar(PerkTree[I]) @ `ShowVar(GetPerkStats(kSold, I).perk, PerkStatsPerk),, 'GetMergedPerk');

				if(perktree[I] == Perk && GetPerkStats(kSold, I).perk > 0)
				{
					return GetPerkStats(kSold, I).perk;
				}
			}
		}
		else
		{

			foreach MergePerk1(mPerk, I)
			{
				Perk1 = SearchPerks(mPerk);
				Perk2 = SearchPerks(MergePerk2[I]);

				if( (MergePerkClass[I] == -1) || (SOLDIERUI().GetAbilityTreeBranch() == 1) ? (MergePerkClass[I] == kSold.GetClass()) : (MergePerkClass[I] == kSold.m_iEnergy) )
				{
					if(Perk1 == Perk)
					{
						return Perk2;
						break;
					}
				}
			}

		}

	}

	return 0;

}

function createPerkArray()
{
	local int I, J, IAlias;
	local EPerkType EPerk;

	for(I=0; I<172; I++)
	{
		EPerk = EPerkType(I);
		arrPerk.AddItem(string(EPerk));
	}

	IAlias = 0;
	for(I=0; I<PerkAliases.Length; I++)
	{
		if(IAlias < PerkAliases[I].Alias.Length)
		{
			IAlias = PerkAliases[I].Alias.Length;
		}
	}

	arrAlias.add(IAlias);

	for(I=0; I<IAlias; I++)
	{
		arrAlias[I].Alias.add(255);
	}

	for(I=0; I<PerkAliases.Length; I++)
	{
		for(J=0; J<PerkAliases[I].Alias.Length; J++)
		{
			if(int(PerkAliases[I].Perk) > 0)
			{
				arrAlias[J].Alias[int(PerkAliases[I].Perk)] = PerkAliases[I].Alias[J];
			}
			else
			{
				if(arrPerk.Find(PerkAliases[I].Perk) != -1)
				{
					arrAlias[J].Alias[arrPerk.Find(PerkAliases[I].Perk)] = PerkAliases[I].Alias[J];
				}
			}
		}
	}
}

function AugmentRestriction()
{
	if(MECxpLoss)
	{
		StrValue0("True");
	}
	else
	{
		StrValue0("False");
	}

	if(MECChops)
	{
		StrValue1("True");
	}
	else
	{
		StrValue1("False");
	}

	if(MECMedalWait)
	{
		StrValue2("True");
	}
	else
	{
		StrValue2("False");
	}
}

function CanNotAugment()
{
	switch(m_kSold.GetStatus())
	{
		case 0:
		case 6:
		case 8:
			if(m_kSold.m_iEnergy == 0)
				StrValue0("True");
			if(m_kSold.IsAugmented())          
				StrValue0("True");
			if((m_kSold.GetPsiRank() > 0) && !MECChops)
				StrValue0("True");
			if(m_kSold.IsATank())
				StrValue0("True");
			if((m_kSold.MedalCount() > 0) && !MECChops)
				StrValue0("True");
			if((m_kSold.GetRank()) < MECxpLoss ? 1 : 2)
				StrValue0("True");

			break;
		default:
            StrValue0("True");
			break;
		}
}

function GiveBackMedals()
{
	local int I;
	local XGStrategySoldier kSold;

	if(m_kSold != none)
		kSold = m_kSold;
	else
		kSold = SOLDIER();

	for(I=0; I<6; I++)
	{
		kSold.m_arrMedals[I] = 0;

		++ kSold.BARRACKS().m_arrMedals[I].m_iAvailable;
		-- kSold.BARRACKS().m_arrMedals[I].m_iUsed;
	}
}

function BuildAugmentMenuOption()
{
	local TTableMenuOption kOption;

	kOption = TMenu().arrOptions[0];
	TMenu(, true);
	if(!MECxpLoss && m_kSold.GetRank() == 1)
	{
		if(kOption.arrStrings[7] != m_kSold.GetStatusString())
		{
			kOption.arrStrings[7] = m_kSold.GetStatusString();
			kOption.arrStates[7] = m_kSold.GetStatusUIState();
		}
	}
	TMenu().arrOptions.AddItem(kOption);
}

function bool PercentRoll(float percent, optional bool isSynced)
{
	local float randfloat;

	if(isSynced)
	{
		if(((class'XComEngine'.static.SyncFRand("") * 100.00) + 1.0) * (100.00 / (101.00 - percent)) > 99.99)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		randfloat = RandRange(0.99991, 100.99991);

		if(StrValue2() == "Check PerkChance")
		{
			`logde(StrValue2() $ ":");
			`logde(`showvar(randfloat));
			`logde(`showvar(randfloat * (100.00 / (101.00 - percent))));
			`logde(`showvar(randfloat * (100.00 / (101.00 - percent)) > 99.99));
			StrValue2("", true);
		}

		if(randfloat * (100.00 / (101.00 - percent)) > 99.99)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}

function GetSoldier(string soldstr)
{

	local XGStrategySoldier Soldier;

	foreach WORLDINFO().AllActors(class'XGStrategySoldier', Soldier)
	{
		if(string(Soldier) == soldstr)
		{
			break;
		}
	}
	m_kSold = Soldier;
}

DefaultProperties
{
}
