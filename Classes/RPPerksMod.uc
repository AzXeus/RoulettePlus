class RPPerksMod extends RoulettePlusMod
	config(RPMisc);

// Structure for information related to the Weapon Specialist Perk
struct TSpecPerk
{
  	var int iItem;
  	var array<int> iClass;
  	var array<int> iPerk;
};

struct TSummaryPerk
{
	var int iPerk;
	var int iValue;
};

var config array<TSummaryPerk> m_arrCritBonusPerks;
var config array<TSummaryPerk> m_arrCritPenaltyPerks;
var config array<TSummaryPerk> m_arrHitBonusPerks;
var config array<TSummaryPerk> m_arrHitPenaltyPerks;
var int iCritCounter;
var config int AmnesiaWillLossAmount;
var config int AmnesiaWillLossType;
var string AmnesiaPerkName;
var string AmnesiaPerkDes;
var config bool bAMedalWait;
var config array<TSpecPerk> specPerk;
var XGUnit m_kUnit;
`ifdebug var XGUnit retainedUnit; `endif
var XGAbility m_lastAbilitiesCheckedUnit;
var array<int> m_arrBUnitAbilitiesList;
var XGStrategySoldier m_kStratSoldier;
var RoulettePlusMod m_kRPlus;
var localized string m_perkNames[255];
var localized string m_perkDesc[255];

// Functions used to access/check parts of the game code
function bool isStrategy()
{
	return XComHeadquartersGame(XComGameInfo(WORLDINFO().Game)) != none;
}

function bool isTactical()
{
	return XComTacticalGame(XComGameInfo(WORLDINFO().Game)) != none;
}

function XGFacility_Labs LABS()
{
    return XComHeadquartersGame(WORLDINFO().Game).GetGameCore().GetHQ().m_kLabs; 
}

function XGFacility_Barracks BARRACKS()
{
    return XComHeadquartersGame(WORLDINFO().Game).GetGameCore().GetHQ().m_kBarracks;
}

function XComPerkManager PERKS()
{
    return XComGameReplicationInfo(WORLDINFO().GRI).m_kPerkTree;   
}

function XGParamTag TAG()
{
	return XGParamTag(XComEngine(class'Engine'.static.GetEngine()).LocalizeContext.FindTag("XGParam"));
}

// Part of the new XComModBridge system to decide which functions to access based on ModBridge calls
simulated function StartMatch()
{
	local array<string> arrStr;
	local XGStrategySoldier kSold;

	if(functionName == "ModInit")
	{
		m_kRPlus = RoulettePlusMod(Mods("RoulettePlus.RoulettePlusMod"));
		m_kRPCheckpoint = m_kRPlus.m_kRPCheckpoint;
		PerkStats = m_kRPlus.PerkStats;
		arrAlias = m_kRPlus.arrAlias;
		arrPerk = m_kRPlus.arrPerk;
		MergePerk1 = m_kRPlus.MergePerk1;
		MergePerk2 = m_kRPlus.MergePerk2;
		expandPerkarray();
	}
	
/*      DEPRECATED
	if(functionName == "XenocideCount")
	{
		ASCSetUnit(StrValue0());
		XenocideCount();
		m_kUnit = none;
	}
	
	if(functionName == "CorruptMessage")
	{
		ASCSetUnit(StrValue0());
		CrruptMessage(StrValue1());
	}
	
	if(functionName == "ASCPerkDescription")
	{
		ASCPerkDescription();
	}
*/
	if(functionName == "XGAbility.ApplyCost_Overwrite")
	{
		AbilityApplyCost();
		m_kRPlus.Object(none, true);
	}

	if(functionName == "GHPD_Overwrite")
	{
		`logd(`ShowVar(SOLDIERUI().GetAbilityTreeBranch()) $ ", " $ `ShowVar(SOLDIERUI().GetAbilityTreeOption()) $ ", pos:'" $ ((SOLDIERUI().GetAbilityTreeBranch() - 1) * 3) + SOLDIERUI().GetAbilityTreeOption());
		`logd(`ShowVar(SOLDIERUI().m_kSoldier.m_kChar.eClass));
/*		DEPRECATED
		ASCSetUnit(StrValue0());

		if(m_kStratSoldier != none)
			kSold = m_kStratSoldier;
		else
			kSold = SOLDIER();

		if(kSold.IsOptionEnabled(4))
*/
		ASCPerkDescription();

//		m_kStratSoldier = none;
	}

	if(functionName == "SetAdvServos")
	{
/*		DEPRECATED
		GetSoldier(StrValue0());
		if(m_kRPlus.Object() != none)
			m_kSold = XGStrategySoldier(m_kRPlus.Object());
*/
		SetAdvServos();
//		m_kSold = none;
	}

	if(functionName == "AISM")
	{
		ASCSetUnit(StrValue0());
	}
	if(functionName == "Strat_Before_GISM")
	{
		//GetSoldier(StrValue0());
		if(m_kRPlus.Object() != none)
			m_kSold = XGStrategySoldier(m_kRPlus.Object());
	}
	if(functionName == "GISM")
	{
		if(m_kUnit != none || m_kSold != none)
		{
			arrStr = SplitString(functParas);
			ModifyStats(int(arrStr[0]), int(arrStr[1]), true);
		}
	}

	if(functionName == "TurnBeginHook")
	{
		ASCSetUnit(StrValue0());
		ResetStates();
		m_kUnit = none;
	}

	if(functionName == "CompleteCombat")
	{
		EmptyAlienStor();
	}

	if(functionName == "ShowAbility")
	{
		if(m_kRPlus.Object() != m_lastAbilitiesCheckedUnit)
		{
			m_lastAbilitiesCheckedUnit = XGAbility(m_kRPlus.Object());
			m_arrBUnitAbilitiesList.Length = 0;
		}
		if(m_arrBUnitAbilitiesList[XGAbility(m_kRPlus.Object()).GetType()] == 0)
		{
			ShowAbility();
		}
		m_arrBUnitAbilitiesList[XGAbility(m_kRPlus.Object()).GetType()] = 1;
	}

	if(functionName == "AbsorbDamage")
	{
		ASCSetUnit(StrValue0());
		AbsorbDamage();

		m_kUnit = none;
	}

	if(functionName == "CheckSoldierStates")
	{
		ASCSetUnit(StrValue0());
		CheckStates("");
		m_kUnit = none;
		m_kStratSoldier = none;
	}

	if(functionName == "ResetSoldierStates")
	{
		ASCSetUnit(StrValue0());
		ResetStates();
		m_kUnit = none;
		m_kStratSoldier = none;
	}
	
	if(functionName == "SetSoldierStates")
	{
		ASCSetUnit(StrValue0());
		SetSoldierStates(functParas);
		m_kUnit = none;
		m_kStratSoldier = none;
	}

	if(functionName == "EmptyAlienStor")
	{
		EmptyAlienStor();
	}
/*      DEPRECATED
	if(functionName == "ASCPerks") 
	{
		arrStr = SplitString(functParas, "_", false);

		ASCSetUnit(arrStr[0]);

		if(arrStr.Length > 3) 
		{
			ASCPerks(arrStr[1], int(arrStr[2]), int(arrStr[3]));
		}
		else 
		{
			ASCPerks(arrStr[1], int(arrStr[2]));
		}
		m_kUnit = none;
		m_kStratSoldier = none;
	}
*/
	if(functionName == "AlienHasPerk")
	{
		ASCSetUnit(StrValue0());
		ASCAlienHasPerk(int(functParas));
		m_kUnit = none;
	}

	if(functionName == "GiveAlienPerk")
	{
		ASCSetUnit(StrValue0());

		arrStr = SplitString(functParas, "_", false);

		if(arrStr.Length > 1)
		{
			ASCAlienGivePerk(int(arrStr[0]), int(arrStr[1]));
		}
		else
		{
			ASCAlienGivePerk(int(arrStr[0]));
		}
		m_kUnit = none;
	}

	if(functionName == "IncapTimer")
	{
		ASCSetUnit(StrValue0());
		IncapTimer();
		m_kUnit = none;
	}
/*      INACTIVE/  Gonna look at a new way to do this in the future.
	if(functionName == "ActivateAmnesia")
	{
		ActivateAmnesia();
	}
*/
	if(functionName == "ResetXenocideCount")
	{
		ASCSetUnit(StrValue0());
		ResetXenocideCount();
		m_kUnit = none;
	}

	if(functionName == "ASCOnKill")
	{
		ASCOnKill(StrValue0(), StrValue1());
	}

	if(functionName == "WepSpec")
    {
    		arrStr = SplitString(functParas, "_", false);
    		WepSpecPerk(int(arrStr[0]), arrStr[1]);
    }



	// New StartMatch() Calls
	if(functionName == "UpdatePerks")
	{
		TRPUpdatePerks();
	}

	if(functionName == "HasUpgrade_Overwrite")
	{
		HasUpgrade_Overwrite(functParas);
	}

	if(functionName == "HasPerk_Overwrite")
	{
		TRPHasPerk(functParas);
	}

	if(functionName == "GivePerk_Overwrite")
	{
		TRPGivePerk(functParas);
	}

	if(functionName == "ClearPerks_Overwrite")
	{
		TRPClearPerks(functParas);
	}

	if(functionName == "ApplyPsiEffect")
	{
		ApplyPsiEffects();
	}

	if(functionName == "CritBonusStart")
	{
		CritBonusStart();
	}

	if(functionName == "CritPenaltyStart")
	{
		CritPenaltyStart();
	}

	if(functionName == "CritBonusLoop")
	{
		CritBonusLoop();
	}

	if(functionName == "CritPenaltyLoop")
	{
		CritPenaltyLoop();
	}

	if(functionName == "HitBonusStart")
	{
		HitBonusStart();
	}

	if(functionName == "HitPenaltyStart")
	{
		HitPenaltyStart();
	}

	if(functionName == "HitBonusLoop")
	{
		HitBonusLoop();
	}

	if(functionName == "HitPenaltyLoop")
	{
		HitPenaltyLoop();
	}

}

// Function to grab the spawn name of a soldier and checks for Strategy/Tactical to set appropriate variable to be used in other functions
function ASCSetUnit(optional string UnitName)
{
	local XGUnit Unit;
	local XGStrategySoldier Soldier;

	if(isTactical())
	{
/*		foreach WORLDINFO().AllActors(class'XGUnit', Unit)
		{
			if(string(Unit) == UnitName)
			{
				break;
			}
		}
		m_kUnit = Unit;
*/	
		if(m_kRPlus.Object() != none)
			m_kUnit = XGUnit(m_kRPlus.Object());

	}
	else if(isStrategy())
	{
/*		foreach WORLDINFO().AllActors(class'XGStrategySoldier', Soldier)
		{
			if(string(Soldier) == UnitName)
			{
				break;
			}
		}
		m_kStratSoldier = Soldier;
*/
		if(m_kRPlus.Object() != none)
			m_kStratSoldier = XGStrategySoldier(m_kRPlus.Object());
	}
}

function TRPUpdatePerks()
{
	local XGUnit kActiveUnit;
	local UITacticalHUD_PerkContainer kPerkContainer;
	local TUIPerkInfo kUIPerkInfo;
	local TPerk kPerk;

	local int i;

	kPerkContainer = UITacticalHUD_PerkContainer(m_kRPlus.Object());
	kActiveUnit = XComTacticalController(PLAYERCONTROLLER()).GetActiveUnit();
	m_kRPlus.Object(kActiveUnit);
	if(kActiveUnit == none)
	{
		return;
	}
	i = 0;
	for(i=173; i < 255; i++)
	{
		kPerk = XComTacticalController(PLAYERCONTROLLER()).PERKS().GetPerk(I);
		if(kPerk.iPerk == 0)
		{
			break;
		}
		if(kPerk.iCategory != 0)
		{
			break;
		}
		if(!kPerk.bShowPerk)
		{
			break;
		}

		if(TRPHasPerk(i))
		{
			kUIPerkInfo.strPerkImage = kPerk.strImage;
			kUIPerkInfo.strPerkName = kPerk.strName[0];
			kUIPerkInfo.strCharges = "";

			m_arrPerkData.AddItem(kUIPerkInfo);
		}
	}
}

function bool TRPHasPerk(int iPerk)
{
	local XGUnit kTactUnit;
	local XGStrategySoldier kStratUnit;
	local int iSoldierID, iPos;
	local bool bIsAlien;
	
	if(isTactical())
	{
		kTactUnit = XGUnit(m_kRPlus.Object());
		if(XGCharacter_Soldier(kTactUnit.GetCharacter()) != none)
		{
			iSoldierID = XGCharacter_Soldier(kTactUnit.GetCharacter()).m_kSoldier.iID;
		}
		else
		{
			bIsAlien = true;
		}
	}
	if(isStrategy())
	{
		kStratUnit = XGStrategySoldier(m_kRPlus.Object());
		iSoldierID = kStratUnit.m_kSoldier.iID;
	}
	
	if(!bIsAlien)
	{
		iPos = m_kRPlus.FindSoldierInStorage(iSoldierID);
	
		if(m_kRPCheckpoint.arrSoldierStorage[iPos].perks[iPerk] > 0)
		{
			StrValue1("True");
			return True;
		}
		else
		{
			StrValue1("False");
			return False;
		}
	}
	/*
	if(bIsAlien)
	{
		
	}
	*/
}

function AbilityApplyCost()
{
	local string strAbility;
	local bool bFound, bOverwrite, IsSoldier, endTurn;
	local XGAbility kAbility;
    local XComUIBroadcastWorldMessage kBroadcastWorldMessage;

/*	strAbility = StrValue0();

	foreach WORLDINFO().AllActors(class'XGAbility', kAbility)
	{
		if(string(kAbility) == strAbility)
		{
			bFound = true;
			break;
		}
	}
	if(!bFound) return;
*/
	
	if(m_kRPlus.Object() != none)
		kAbility = XGAbility(m_kRPlus.Object());

	if(kAbility.HasProperty(8) || kAbility.m_bReactionFire) return;

	if(XGCharacter_Soldier(kAbility.m_kUnit.GetCharacter()) != none)
		IsSoldier = true;

	if( m_kRPlus.IsCommandFree &&
		kAbility.GetType() == 41 )
			bOverwrite = true;

	if(kAbility.GetType() == 7)
	{
		if( !m_kRPlus.UseOldITZInteraction && XGAbility_Targeted(kAbility) != none &&
			kAbility.m_kUnit.GetCharacter().HasUpgrade(14) && XGAction_Fire(kAbility.m_kUnit.m_kCurrAction) != none && XGAction_Fire(kAbility.m_kUnit.m_kCurrAction).m_kShot == XGAbility_Targeted(kAbility) && XGAction_Fire(kAbility.m_kUnit.m_kCurrAction).IsKillShot() &&			
			( XGAbility_Targeted(kAbility).m_bHit && !XGAbility_Targeted(kAbility).m_bReflected && ( XGAbility_Targeted(kAbility).m_bHasFlank || XGAbility_Targeted(kAbility).m_bHasOpenTarget ) ) )
		{
			bOverwrite = true;
			++ kAbility.m_kUnit.m_iFireActionsPerformed;
		}

		if( !bOverwrite && XGAbility_Targeted(kAbility) != none &&
			kAbility.m_kUnit.GetCharacter().HasUpgrade(34) && !kAbility.m_kUnit.m_bCloseAndPersonalTaken && !kAbility.m_kUnit.m_bRunAndGunActivated &&
			VSize(kAbility.m_kUnit.Location - XGAbility_Targeted(kAbility).GetPrimaryTarget().Location) <= float(6 * 64) )
		{

			if(retUnitPos(kAbility.m_kUnit) == -1)
				CreateUnitStor(kAbility.m_kUnit);
			
			m_kUnit = kAbility.m_kUnit;
			if(!CheckStates("CloseEncounters"))
			{
				bOverwrite = true;
				kAbility.m_kUnit.m_bCloseAndPersonalTaken = true;
				
				if(IsSoldier)
					m_kRPCheckpoint.arrSoldierStorage[retUnitPos(kAbility.m_kUnit)].bCETaken = true;
				else
					m_kRPCheckpoint.arrAlienStorage[retUnitPos(kAbility.m_kUnit)].bCETaken = true;
			}

			m_kUnit = none;
		}
		if( !bOverwrite && XGAbility_Targeted(kAbility) != none &&
			kAbility.m_kUnit.GetCharacter().HasUpgrade(167) && !XGAbility_Targeted(kAbility).GetPrimaryTarget().IsFlying() && !kAbility.m_kUnit.m_bRunAndGunActivated &&
			( !XGAbility_Targeted(kAbility).GetPrimaryTarget().IsInCover() || XGAbility_Targeted(kAbility).GetPrimaryTarget().IsFlankedByLoc(kAbility.m_kUnit.Location) || XGAbility_Targeted(kAbility).GetPrimaryTarget().IsFlankedBy(kAbility.m_kUnit) ) )
		{

			if(retUnitPos(kAbility.m_kUnit) == -1)
				CreateUnitStor(kAbility.m_kUnit);

			m_kUnit = kAbility.m_kUnit;
			if(!CheckStates("HitandRun"))
			{

				kBroadcastWorldMessage = XComPresentationLayer(XComPlayerController(PLAYERCONTROLLER()).m_Pres).GetWorldMessenger().Message(XComGameReplicationInfo(WORLDINFO().GRI).m_kGameCore.GetUnexpandedLocalizedMessageString(0), kAbility.m_kUnit.Location, 3,,, kAbility.m_kUnit.m_eTeamVisibilityFlags,,,, class'XComUIBroadcastWorldMessage_UnexpandedLocalizedString');

				if(kBroadcastWorldMessage != none)
					XComUIBroadcastWorldMessage_UnexpandedLocalizedString(kBroadcastWorldMessage).Init_UnexpandedLocalizedString(0, kAbility.m_kUnit.Location, 3, kAbility.m_kUnit.m_eTeamVisibilityFlags);

				kAbility.m_kUnit.m_bCloseAndPersonalTaken = true;
				bOverwrite = true;

				if(IsSoldier)
					m_kRPCheckpoint.arrSoldierStorage[retUnitPos(kAbility.m_kUnit)].bHnRTaken = true;
				else
					m_kRPCheckpoint.arrAlienStorage[retUnitPos(kAbility.m_kUnit)].bHnRTaken = true;
			}

			m_kUnit = none;
		}
		if(!bOverwrite && kAbility.m_kUnit.GetCharacter().HasUpgrade(126))
		{
			++ kAbility.m_kUnit.m_iMovesActionsPerformed;
			bOverwrite = true;
		}
	}

	if(bOverwrite)
		StrValue0("True");
}

function SetAdvServos()
{
	if(m_kRPlus.Object() != none)
		m_kSold = XGStrategySoldier(m_kRPlus.Object());
	
	if(m_kRPCheckpoint.arrSoldierStorage.Length == 0 || FindSoldierInStorage(, m_kSold) == -1)
		CreateSoldierStor(m_kSold);

	m_kRPCheckpoint.arrSoldierStorage[FindSoldierInStorage(, m_kSold)].advServos = true;

	m_kSold = none;
}

function ModifyStats(int iStat, int iEquippedWeapon, optional bool bLoop)
{
	local int soldID;

	if(isStrategy())
		soldID = m_kSold.m_kSoldier.iID;
	else
		soldID = XGCharacter_Soldier(m_kUnit.GetCharacter()).m_kSoldier.iID;

	if(iStat == 3)
	{
		if(m_kRPCheckpoint.arrSoldierStorage.Length > 0) 
		{
			if(XGCharacter_Soldier(m_kUnit.GetCharacter()) != none && FindSoldierInStorage(soldID) != -1)
			{
				if(m_kRPCheckpoint.arrSoldierStorage[FindSoldierInStorage(soldID)].advServos)
					IntValue0(IntValue0() + 4, true);
			}
		}
	}

	if(!bLoop || iStat == 18)
	{
		m_kUnit = none;
		m_kSold = none;
	}
}

function int CreateUnitStor(XGUnit Unit)
{
	local int pos;

	pos = -1;

	if(XGCharacter_Soldier(Unit.GetCharacter()) != none)
	{
		pos = m_kRPCheckpoint.arrSoldierStorage.Length;

		m_kRPCheckpoint.arrSoldierStorage.Add(1);
		m_kRPCheckpoint.arrSoldierStorage[pos].SoldierID = XGCharacter_Soldier(Unit.GetCharacter()).m_kSoldier.iID;
	}
	else
	{
		pos = m_kRPCheckpoint.arrAlienStorage.Length;

		m_kRPCheckpoint.arrAlienStorage.Add(1);
		m_kRPCheckpoint.arrAlienStorage[pos].ActorNumber = int(GetRightMost(String(Unit)));
	}

	return pos;
}
	
function int retUnitPos(XGUnit Unit)
{
	local int I;
	local bool bFound;

	if(XGCharacter_Soldier(Unit.GetCharacter()) != none)
	{
		if(m_kRPCheckpoint.arrSoldierStorage.Length == 0)
			return -1;

		for(I=0; I<m_kRPCheckpoint.arrSoldierStorage.Length; I++)
		{
			if(m_kRPCheckpoint.arrSoldierStorage[I].SoldierID == XGCharacter_Soldier(Unit.GetCharacter()).m_kSoldier.iID)
			{
				bFound = true;
				break;
			}
		}
	}
	else
	{
		if(m_kRPCheckpoint.arrAlienStorage.Length == 0)
			return -1;
		
		for(I=0; I<m_kRPCheckpoint.arrAlienStorage.Length; I++)
		{
			if(m_kRPCheckpoint.arrAlienStorage[I].ActorNumber == int(GetRightMost(string(Unit))))
			{
				bFound = true;
				break;
			}
		}
	}
	if(bFound)
		return I;
	else
		return -1;
}

function ShowAbility()
{
	local string strAbility;
	local bool bFound;
	local XGAbility kAbility;
	local int I;

/*	strAbility = StrValue0();
	
	foreach WORLDINFO().AllActors(class'XGAbility', kAbility)
	{
		I += 1;
		if(string(kAbility) == strAbility)
		{
			bFound = true;
			break;
		}
	}

	ScriptTrace();
*/
	if (m_kRPlus.Object() != none)
		kAbility = XGAbility(m_kRPlus.Object());


	`logde("ShowAbility Iterated " $ I $ " times");
	`logde("Ability Name: '" $ kAbility.strName $ "'");
	`logde("Ability Unit: '" $ kAbility.m_kUnit $ "'");
	`ifdebug
		if(kAbility.m_kUnit != retainedUnit)
		{
			retainedUnit = kAbility.m_kUnit;
			`logde("Ability SoldierName: '" $ (XGCharacter_Soldier(kAbility.m_kUnit.GetCharacter()) != none ? XGCharacter_Soldier(kAbility.m_kUnit.GetCharacter()).GetFullName() : "[NOT A SOLDIER]") $ "'");
		}
	`endif

//	if(!bFound) return;

	if(kAbility.HasDisplayProperty(1) || ( !kAbility.CheckAvailable() && kAbility.HasDisplayProperty(2) ) ) return;

	if(kAbility.m_kUnit.GetInventory().GetActiveWeapon().HasProperty(16))
	{
		if(kAbility.m_kUnit.RunAndGunPerkActive() || ( m_kRPlus.UseLWBetaRnGInteraction && kAbility.m_kUnit.GetCharacter().HasUpgrade(6) ) )
		{
			switch(kAbility.GetType())
			{
				case 7:
				case 8:
				case 53:
				case 12:
				case 13:
				case 48:
				case 49:
				case 22:
					StrValue0("True");
				default:
					break;
			}
		}
	}
}


function AbsorbDamage()
{
	local float fDR;

	fDR = 0.f;
	if(m_kUnit.IsAugmented() && m_kUnit.m_bOneForAllActive && m_kUnit.GetCharacter().HasUpgrade(17))
	{
		fDR += 1.5;
	}

	IntValue0(IntValue0() + int(fDR * 100), true);
}

// Clears all aliens' perks
function EmptyAlienStor()
{
	m_kRPCheckpoint.arrAlienStorage.Length = 0;
}

// Allows editing of perk descriptions on the Ability Screen
function ASCPerkDescription()
{
    local int iPerk, iPos, Perk1, Perk2, I;
	local string Output, mPerk;
	local XGStrategySoldier kSold;
	local TStatStorage StatsStor;

	if(m_kStratSoldier != none)
		kSold = m_kStratSoldier;
	else
		kSold = SOLDIER();
	
	if(!kSold.IsOptionEnabled(4))
	{
		return;
	}

	`Logde("ASCPerkDescription");

	`Logde("kSold= " $ string(kSold));

	if(SOLDIERUI().m_iCurrentView != 2)
	{
		iPos = ((SOLDIERUI().GetAbilityTreeBranch() - 1) * 3) + SOLDIERUI().GetAbilityTreeOption();

		if(isSoldierNewType(kSold) && SOLDIERUI().GetAbilityTreeBranch() != 1)
		{
			`Logde("IsNewType");

			iPerk = NewRandomTree(kSold, -1)[iPos];

			`Logde("iPerk= " $ string(iPerk));
			
			StatsStor = GetPerkStats(kSold, iPos);
		}
		else
		{
			if(kSold.m_arrRandomPerks.Length > 0)
				iPerk = kSold.m_arrRandomPerks[iPos];
			else
				iPerk = 0;

			if(SOLDIERUI().GetAbilityTreeBranch() == 1)
				iPerk = kSold.PERKS().GetPerkInTree(kSold.GetClass() == 6 ? kSold.m_iEnergy : kSold.GetClass(), 1, SOLDIERUI().GetAbilityTreeOption(), false);
			
			OldPerkStats(iPos, true);
			StatsStor.aim = arrInts()[0];
			StatsStor.will = arrInts()[1];
			StatsStor.hp = arrInts()[2];
			StatsStor.mob = arrInts()[3];
			StatsStor.def = arrInts()[4];
			
			foreach m_kRPlus.MergePerk1(mPerk, I)
			{
				Perk1 = m_kRPlus.SearchPerks(mPerk);
				Perk2 = m_kRPlus.SearchPerks(MergePerk2[I]);
				
				if( (m_kRPlus.MergePerkClass[I] == -1) || (SOLDIERUI().GetAbilityTreeBranch() == 1) ? (m_kRPlus.MergePerkClass[I] == kSold.GetClass()) : (m_kRPlus.MergePerkClass[I] == kSold.m_iEnergy) )
				{
					if(Perk1 == iPerk)
					{
						StatsStor.perk = Perk2;
						break;
					}
				}
			}
		}

		if((!m_kRPlus.bHideEmptyStatStr || StatsStor.def != 0 || StatsStor.HP != 0 || StatsStor.mob != 0 || StatsStor.will != 0 || StatsStor.aim != 0) && iPerk != 46)
		{
			Output =  Left(class'XComLocalizer'.static.ExpandString(SOLDIERUI().m_strLockedAbilityDescription), InStr(class'XComLocalizer'.static.ExpandString(SOLDIERUI().m_strLockedAbilityDescription), ":") + 1) $ "( ";
			Output $= (StatsStor.aim != 0 ? (class'UIStrategyComponent_SoldierStats'.default.m_strStatOffense @ StatsStor.aim) : "");
			Output $= (StatsStor.will != 0 ? ((StatsStor.aim != 0 ? ", " : "") $ class'UIStrategyComponent_SoldierStats'.default.m_strStatWill @ StatsStor.will) : "");
			Output $= (StatsStor.mob != 0 ? (((StatsStor.will != 0 || StatsStor.aim != 0) ? ", " : "") $ Left(SOLDIERUI().m_strLabelMobility, Len(SOLDIERUI().m_strLabelMobility) - 1) $ ":" @ StatsStor.mob) : "");
			Output $= (StatsStor.HP != 0 ? (((StatsStor.mob != 0 || StatsStor.will != 0 || StatsStor.aim != 0) ? ", " : "") $ class'UIStrategyComponent_SoldierStats'.default.m_strStatHealth @ StatsStor.HP) : "");
			Output $= (StatsStor.def != 0 ? (((StatsStor.HP != 0 || StatsStor.mob != 0 || StatsStor.will != 0 || StatsStor.aim != 0) ? ", " : "") $ class'UIStrategyComponent_SoldierStats'.default.m_strStatDefense @ StatsStor.def) : "") @ ")";
			Output $= class'XComLocalizer'.static.ExpandString("\\n");
		}
		
		if(StatsStor.perk > 0)
			Output $= "<font color='" $ (m_kRPlus.strMergePerkColor != "" ? m_kRPlus.strMergePerkColor : "#5CD16C") $ "'>" $ m_kRPlus.strMergePerkLabel $ ":(" @ kSold.PERKS().GetPerkName(StatsStor.perk) @ ")</font>" $ class'XComLocalizer'.static.ExpandString("\\n");
		
		Output $= kSold.PERKS().GetBriefSummary(iPerk);
		
		if(StatsStor.perk > 0)
			Output $= class'XComLocalizer'.static.ExpandString("\\n") $ "<font color='" $ (m_kRPlus.strMergePerkColor != "" ? m_kRPlus.strMergePerkColor : "#5CD16C") $ "'>" $ m_kRPlus.strMergePerkDes $ ":(" @ kSold.PERKS().GetBriefSummary(StatsStor.perk) @ ")</font>";
		
			
		StrValue0("True");
		StrValue1(Output, true);
	}
	m_kStratSoldier = none;
}

// Checks for, Adds, or Removes new perks(perks not from Long War)
function ASCPerks(string funct, int perk, optional int value = 1)
{
	
	local int I, SID;
	local bool bFound;

	if(isStrategy())
	{
		SID = m_kStratSoldier.m_kSoldier.iID;
	}
	else
	{
		SID = XGCharacter_Soldier(m_kUnit.GetCharacter()).m_kSoldier.iID;
	}
/*
	if(funct == "HasPerk")
	{
		IntValue0(0, true);
		for(I=0; I<m_kRPCheckpoint.arrSoldierStorage.Length; I++)
		{
			if(SID == m_kRPCheckpoint.arrSoldierStorage[I].SoldierID)
			{
				if(m_kRPCheckpoint.arrSoldierStorage[I].perks[perk] > 0)
				{
					IntValue0(m_kRPCheckpoint.arrSoldierStorage[I].perks[perk], true);
				}
			}
				
		}
		
	}
*/
	if(funct == "GivePerk")
	{
		bFound = false;
		IntValue0(0, true);
		for(I=0; I<m_kRPCheckpoint.arrSoldierStorage.Length; I++)
		{
			if(SID == m_kRPCheckpoint.arrSoldierStorage[I].SoldierID)
			{
				bFound = true;
				m_kRPCheckpoint.arrSoldierStorage[I].perks[perk] += value;
			}
		}

		if(!bFound)
		{
			m_kRPCheckpoint.arrSoldierStorage.Add(1);
			m_kRPCheckpoint.arrSoldierStorage[m_kRPCheckpoint.arrSoldierStorage.Length-1].SoldierID = SID;
			m_kRPCheckpoint.arrSoldierStorage[m_kRPCheckpoint.arrSoldierStorage.Length-1].perks[perk] = value;
		}
		
	}
	if(funct == "RemovePerk")
    {
		IntValue0(0, true);
		for(I=0; I<m_kRPCheckpoint.arrSoldierStorage.Length; I++)
		{
			if(SID == m_kRPCheckpoint.arrSoldierStorage[I].SoldierID)
			{
				if(m_kRPCheckpoint.arrSoldierStorage[I].perks[perk] > 0)
				{
					m_kRPCheckpoint.arrSoldierStorage[I].perks[perk] -= value;
				}
			}
		}
	}
}

// This is where the magic happens, increases the number of perks that can be allowed in the game(increases size of array in PerkManager)
function expandPerkarray()
{
	local XComPerkManager kPerkMan;
	
	if(IsStrategy())
		kPerkMan = BARRACKS().m_kPerkManager;
	else if(IsTactical())
		kPerkMan = PERKS();
	else
		return;	

	stperkman:
	kPerkMan.m_arrPerks.Length = 255;
	
	LogInternal(String(kPerkMan), 'expandPerkarray');
	
	kPerkMan.BuildPerk(116, 0, "Evasion");								// Changing icons for existing perks
	kPerkMan.BuildPerk(80, 1, "Flying");
	kPerkMan.BuildPerk(83, 1, "Poisoned");
	kPerkMan.BuildPerk(84, 1, "Poisoned");
    kPerkMan.BuildPerk(85, 1, "Adrenal");
    kPerkMan.BuildPerk(76, 0, "ReinforcedArmor");

	
	kPerkMan.BuildPerk(173, 0, "Unknown");								// Assigns the icon
	kPerkMan.m_arrPerks[173].strName[0] = m_perkNames[173];				// Assigns the name from a localized file
	kPerkMan.m_arrPerks[173].strDescription[0] = m_perkDesc[173];		// assigns the description from a localized file
	
	kPerkMan.BuildPerk(174, 0, "RifleSuppression");
	kPerkMan.m_arrPerks[174].strName[0] = m_perkNames[174];
	kPerkMan.m_arrPerks[174].strDescription[0] = m_perkDesc[174];
	
	kPerkMan.BuildPerk(175, 0, "ExpandedStorage");
	kPerkMan.m_arrPerks[175].strName[0] = m_perkNames[175];
	kPerkMan.m_arrPerks[175].strDescription[0] = m_perkDesc[175];
	
	kPerkMan.BuildPerk(176, 0, "PoisonSpit");
	kPerkMan.m_arrPerks[176].strName[0] = m_perkNames[176];
	kPerkMan.m_arrPerks[176].strDescription[0] = m_perkDesc[176];
	
	kPerkMan.BuildPerk(177, 0, "Launch");
	kPerkMan.m_arrPerks[177].strName[0] = m_perkNames[177];
	kPerkMan.m_arrPerks[177].strDescription[0] = m_perkDesc[177];
	
	kPerkMan.BuildPerk(178, 0, "Bloodcall");
	kPerkMan.m_arrPerks[178].strName[0] = m_perkNames[178];
	kPerkMan.m_arrPerks[178].strDescription[0] = m_perkDesc[178];
	
	kPerkMan.BuildPerk(179, 0, "UrbanDefense");
	kPerkMan.m_arrPerks[179].strName[0] = m_perkNames[179];
	kPerkMan.m_arrPerks[179].strDescription[0] = m_perkDesc[179];
	
	kPerkMan.BuildPerk(180, 0, "Harden");
	kPerkMan.m_arrPerks[180].strName[0] = m_perkNames[180];
	kPerkMan.m_arrPerks[180].strDescription[0] = m_perkDesc[180];
	
	kPerkMan.BuildPerk(181, 0, "Intimidate");
	kPerkMan.m_arrPerks[181].strName[0] = m_perkNames[181];
	kPerkMan.m_arrPerks[181].strDescription[0] = m_perkDesc[181];
	
	kPerkMan.BuildPerk(189, 0, "Disoriented");
	kPerkMan.m_arrPerks[189].strName[0] = m_perkNames[189];
	kPerkMan.m_arrPerks[189].strDescription[0] = m_perkDesc[189];
	
	kPerkMan.BuildPerk(190, 0, "ReactivePupils");
	kPerkMan.m_arrPerks[190].strName[0] = m_perkNames[190];
	kPerkMan.m_arrPerks[190].strDescription[0] = m_perkDesc[190];
	
	kPerkMan.BuildPerk(191, 0, "Stun");
	kPerkMan.m_arrPerks[191].strName[0] = m_perkNames[191];
	kPerkMan.m_arrPerks[191].strDescription[0] = m_perkDesc[191];	
	
	kPerkMan.BuildPerk(192, 0, "Stun");
	kPerkMan.m_arrPerks[192].strName[0] = m_perkNames[192];
	kPerkMan.m_arrPerks[192].strDescription[0] = m_perkDesc[192];
	
	
	if(kPerkMan != PERKS())
    {
		kPerkMan = PERKS();
		goto stperkman;
	}
	
}

// Assigns and removes perks based on item(s) equipeed to a soldier
function WepSpecPerk(int iItemType, string funct)
{
	local int I, J;
  	local bool bFound;

	for(I = 0; I < specPerk.length; I ++)
    {
        if(iItemType == specPerk[I].iItem)
        {
          	for(J = 0; J < specPerk[I].iClass.length; J ++)
          	{
              	bFound = false;
            	if(specPerk[I].iClass[J] == -1 || specPerk[I].iClass[J] == SOLDIER().m_iEnergy)
            	{
                	if(funct == "add")
                	{
						if(specPerk[I].iPerk[J] > 0)
						{
                    		SOLDIER().m_kChar.aUpgrades[specPerk[I].iPerk[J]] += 2;
                      		bFound = true;
                  			break;
						}
                	}
                	if(funct == "rem")
                	{
						if(specPerk[I].iPerk[J] > 0)
						{
                    		if(SOLDIER().m_kChar.aUpgrades[specPerk[I].iPerk[J]] > 1)
                    		{
                        		SOLDIER().m_kChar.aUpgrades[specPerk[I].iPerk[J]] -= 2;
                          		bFound = true;
                      			break;
							}
						}
                    }
                }
            }
          	if(bFound)
            {
              	break;
            }
        }
    }
}

// Does things when a soldier or enemy is killed
function ASCOnKill(string Unit, string Victim)
{
	local XGUnit kUnit, kVictim;
	local TSoldierStorage SoldStor, SoldStor1;
	local bool bFound;
	local int I;
	
	foreach WORLDINFO().AllActors(Class'XGUnit', kUnit)
	{
		if(string(kUnit) == Victim)
		{
			kVictim = kUnit;
		}
		if(string(kUnit) == Unit)
		{
			m_kUnit = kUnit;
		}
	}
	
	if(XGCharacter_Soldier(m_kUnit.GetCharacter()) != none)
	{
		ASCPerks("HasPerk", XGCharacter_Soldier(m_kUnit.GetCharacter()).m_kSoldier.iID, 180);
		if(IntValue0() > 0)
		{
			m_kUnit.m_aCurrentStats[7] += 1;
			m_kUnit.m_aCurrentStats[13] += 1;

			bFound = false;
			foreach m_kRPCheckpoint.arrSoldierStorage(SoldStor, I)
			{
				if(SoldStor.SoldierID == XGCharacter_Soldier(m_kUnit.GetCharacter()).m_kSoldier.iID)
				{
					++ m_kRPCheckpoint.arrSoldierStorage[I].XenocideCount;
					bFound = true;
					break;
				}
			}

			if(!bFound)
			{
				SoldStor1.SoldierID = XGCharacter_Soldier(m_kUnit.GetCharacter()).m_kSoldier.iID;
				SoldStor1.XenocideCount = 1;
				m_kRPCheckpoint.arrSoldierStorage.AddItem(SoldStor1);
			}
		}
	}
	m_kUnit = none;
}

// Counter to keep track of kills for Xenocide perk
function XenocideCount()
{
	local int Count;
	local bool bFound;
	local TSoldierStorage SoldStor;
	
	bFound = false;
	foreach m_kRPCheckpoint.arrSoldierStorage(SoldStor)
	{
		if(SoldStor.SoldierID == XGCharacter_Soldier(m_kUnit.GetCharacter()).m_kSoldier.iID)
		{
			Count = SoldStor.XenocideCount * 3;
			bFound = true;
			break;
		}
	}

	if(!bFound)
	{
		Count = 0;
	}
	// Changed from TAG().IntValue2
	IntValue0(Count);
	m_kUnit = none;
}

// Resets the Xenocide count for each soldier
function ResetXenocideCount()
{
	local TSoldierStorage SoldStor;
	local int I;
	
	foreach m_kRPCheckpoint.arrSoldierStorage(SoldStor, I)
	{
		if(SoldStor.SoldierID == XGCharacter_Soldier(m_kUnit.GetCharacter()).m_kSoldier.iID)
		{
			m_kRPCheckpoint.arrSoldierStorage[I].XenocideCount = 0;
			break;
		}
	}
	m_kUnit = none;
}

// Checks if an alien has a perk
function ASCAlienHasPerk(int iPerk)
{

	local TAlienStorage AlienStor;
	local bool bFound;

	IntValue2(0,  true);
	bFound = False;
	foreach m_kRPCheckpoint.arrAlienStorage(AlienStor)
	{
		if(int(GetRightMost(String(m_kUnit))) == AlienStor.ActorNumber)
		{
			bFound = true;
			break;
		}
	}
	if(bFound)
	{
		IntValue2(AlienStor.perks[iPerk], true);
	}
	else
	{
		IntValue2(0, true);
	}
	LogInternal("IntValue2= " $ IntValue2(), 'ASCAlienHasPerk');
}

// Assigns new perks to aliens
function ASCAlienGivePerk(int iPerk, optional int Value)
{
	local TAlienStorage AlienStor, AlienStor1;
	local int I;
	local bool bFound;

	bFound = False;
	foreach m_kRPCheckpoint.arrAlienStorage(AlienStor, I)
	{
		if(int(GetRightMost(String(m_kUnit))) == AlienStor.ActorNumber)
		{
			bFound = true;
			if(Value > 0)
			{
				m_kRPCheckpoint.arrAlienStorage[I].perks[iPerk] += Value;
			}
			else
			{
				m_kRPCheckpoint.arrAlienStorage[I].perks[iPerk] += 1;
			}
			break;
		}
	}
	if(!bFound)
	{
		AlienStor1.ActorNumber = int(GetRightMost(String(m_kUnit)));
		if(Value > 0)
		{
			AlienStor1.perks[iPerk] += Value;
		}
		else
		{
			AlienStor1.perks[iPerk] += 1;
		}
		m_kRPCheckpoint.arrAlienStorage.AddItem(AlienStor1);
	}
}

// Removes a perk from an alien
function ASCAlienRemovePerk(int iPerk, optional int Value)
{
	local TAlienStorage AlienStor;
	local int I;

	foreach m_kRPCheckpoint.arrAlienStorage(AlienStor, I)
	{
		if(int(GetRightMost(String(m_kUnit))) == AlienStor.ActorNumber)
		{
			if(Value > 0 && Value >= AlienStor.perks[iPerk])
			{
				m_kRPCheckpoint.arrAlienStorage[I].perks[iPerk] -= Value;
			}
			else
			{
				m_kRPCheckpoint.arrAlienStorage[I].perks[iPerk] = 0;
			}
			break;
		}
	}
}

// Counter for how long Incapacitation affects an enemy
function IncapTimer()
{
	local TAlienStorage AlienStor, AlienStor1;
	local int I;
	local bool bFound;

	bFound = False;
	foreach m_kRPCheckpoint.arrAlienStorage(AlienStor, I)
	{
		if(int(GetRightMost(String(m_kUnit))) == AlienStor.ActorNumber)
		{

			if( ++ m_kRPCheckpoint.arrAlienStorage[I].IncapTimer == 2)
			{
				ASCAlienRemovePerk(192);
				m_kUnit.ApplyInventoryStatModifiers();
				m_kRPCheckpoint.arrAlienStorage[I].IncapTimer = 0;
			}
			bFound = true;
		}
	}
	if(!bFound)
	{
		AlienStor1.ActorNumber = int(GetRightMost(String(m_kUnit)));
		AlienStor1.IncapTimer = 1;
		m_kRPCheckpoint.arrAlienStorage.AddItem(AlienStor1);
	}
	m_kUnit = none;
}

// Function to reset perks, stats, and other bonuses from leveling up(also removes starting rookie perk)
function ActivateAmnesia()
{
	local int iCount;

	SOLDIER().ClearPerks(true);
	
	SOLDIER().m_arrRandomPerks.Length = 0;

	SOLDIER().m_kChar.aStats[0] = class'XGTacticalGameCore'.default.Characters[1].HP;
	SOLDIER().m_kChar.aStats[1] = class'XGTacticalGameCore'.default.Characters[1].Offense;
	SOLDIER().m_kChar.aStats[2] = class'XGTacticalGameCore'.default.Characters[1].Defense;
	SOLDIER().m_kChar.aStats[3] = class'XGTacticalGameCore'.default.Characters[1].Mobility;
	SOLDIER().m_kChar.aStats[7] = class'XGTacticalGameCore'.default.Characters[1].Will;

	BARRACKS().RandomizeStats(SOLDIER());

	if(SOLDIER().HasAnyMedal()) 
	{		
		if(bAMedalWait) 
		{
			BARRACKS().rollstat(SOLDIER(), 0, 0);
		}
		else
		{ 
			for(iCount = SOLDIER().MedalCount(); iCount > 0; iCount --)
			{		
				SOLDIER().m_arrMedals[iCount] = 0;
				BARRACKS().m_arrMedals[iCount].m_iUsed -= 1;
				BARRACKS().m_arrMedals[iCount].m_iAvailable += 1;
			}
		}
	}
}

// Set/Reset/Check SoldierStates set flags to let the game know if something has happened to a specific soldier
function SetSoldierStates(string sstate)
{
	local TSoldierStorage SS;
	local int I, SID;

	if(isStrategy())
	{
		SID = m_kStratSoldier.m_kSoldier.iID;
	}
	else
	{
		SID = XGCharacter_Soldier(m_kUnit.GetCharacter()).m_kSoldier.iID;
	}

	foreach m_kRPCheckpoint.arrSoldierStorage(SS, I)
	{
		if(SS.SoldierID == SID)
		{
			if(sstate == "Gunslinger")
			{
				m_kRPCheckpoint.arrSoldierStorage[I].GunslingerState = true;
				break;
			}
		}
	}
}

function ResetStates()
{
	local int pos;

	pos = retUnitPos(m_kUnit);

	if(XGCharacter_Soldier(m_kUnit.GetCharacter()) != none)
	{
		m_kRPCheckpoint.arrSoldierStorage[pos].GunslingerState = false;
		m_kRPCheckpoint.arrSoldierStorage[pos].bCETaken = false;
		m_kRPCheckpoint.arrSoldierStorage[pos].bHnRTaken = false;
		m_kRPCheckpoint.arrSoldierStorage[pos].state.Length = 0;
	}
	else
	{
		m_kRPCheckpoint.arrSoldierStorage[pos].GunslingerState = false;
		m_kRPCheckpoint.arrSoldierStorage[pos].bCETaken = false;
		m_kRPCheckpoint.arrSoldierStorage[pos].bHnRTaken = false;
		m_kRPCheckpoint.arrSoldierStorage[pos].state.Length = 0;
	}
}


function bool CheckStates(string state)
{
	local int pos;

	pos = retUnitPos(m_kUnit);

	if(XGCharacter_Soldier(m_kUnit.GetCharacter()) != none)
	{
		switch(state)
		{
			case "HitandRun":
				return  m_kRPCheckpoint.arrSoldierStorage[pos].bHnRTaken;
			case "GunSlinger":
				return m_kRPCheckpoint.arrSoldierStorage[pos].GunslingerState;
			case "CloseEncounters":
				return m_kRPCheckpoint.arrSoldierStorage[pos].bCETaken;
			default:
				return m_kRPCheckpoint.arrSoldierStorage[pos].state[int(state)] != 0;
		}
	}
	else
	{
		switch(state)
		{
			case "HitandRun":
				return  m_kRPCheckpoint.arrAlienStorage[pos].bHnRTaken;
			case "GunSlinger":
				return m_kRPCheckpoint.arrAlienStorage[pos].GunslingerState;
			case "CloseEncounters":
				return m_kRPCheckpoint.arrAlienStorage[pos].bCETaken;
			default:
				return m_kRPCheckpoint.arrAlienStorage[pos].state[int(state)] != 0;
		}
	}
}

function CritBonusStart()
{
	local array<int> arrPerks;
	
	arrPerks = m_arrCritBonusPerks;

	if(arrPerks.Length > 0)
	{
		StrValue0("True");
		iCounter = 0;
	}
}

function CritPenaltyStart()
{
	local array<int> arrPerks;
	
	arrPerks = m_arrCritPenaltyPerks;

	if(arrPerks.Length > 0)
	{
		StrValue0("True");
		iCounter = 0;
	}
}

function CritBonusLoop()
{
	local XGAbility_Targeted kAbility;
	local XGUnit kUnit;

	kAbility = XGAbility_Targeted(m_kRPlus.Object());
	kUhit = kAbility.m_kUnit;

	if(m_arrCritBonusPerks.iPerk == 180)
	{
		if(kUnit.GetCharacter().HasUpgrade(180))
		{
			StrValue1(m_perkNames[m_arrCritBonusPerks.iPerk]);
			IntValue0(m_arrCritBonusPerks.iValue);
		}
	}

	if(m_arrCritBonusPerks.iPerk == 190)
	{
		if(kUnit.GetCharacter().HasUpgrade(190) && kAbility.GetPrimaryTarget().IsVulnerableToElectropulse())
		{
			StrValue1(m_perkNames[m_arrCritBonusPerks.iPerk]);
			IntValue0(m_arrCritBonusPerks.iValue);
		}
	}

	iCounter++;
	if(iCounter > m_arrCritBonusPerks.Length)
	{
		StrValue0("False");
	}
}

function CritPenaltyLoop()
{
	local XGAbility_Targeted kAbility;
	local XGUnit kUnit;

	kAbility = XGAbility_Targeted(m_kRPlus.Object());
	kUhit = kAbility.m_kUnit;

	if(m_arrCritPenaltyPerks.iPerk == 179)
	{
		if(kAbility.GetPrimaryTarget().GetCharacter().HasUpgrade(179))
		{
			StrValue1(m_perkNames[m_arrCritPenaltyPerks.iPerk]);
			IntValue0(m_arrCritPenaltyPerks.iValue);
		}
	}

	iCounter++;
	if(iCounter > m_arrCritPenaltyPerks.Length)
	{
		StrValue0("False");
	}
}

function HitBonusStart()
{
	local array<int> arrPerks;
	
	arrPerks = m_arrHitBonusPerks;

	if(arrPerks.Length > 0)
	{
		StrValue0("True");
		iCounter = 0;
	}
}

function HitPenaltyStart()
{
	local array<int> arrPerks;
	
	arrPerks = m_arrHitPenaltyPerks;

	if(arrPerks.Length > 0)
	{
		StrValue0("True");
		iCounter = 0;
	}
}

function HitBonusLoop()
{
	local XGAbility_Targeted kAbility;
	local XGUnit kUnit;

	kAbility = XGAbility_Targeted(m_kRPlus.Object());
	kUhit = kAbility.m_kUnit;
/*
	if(m_arrHitBonusPerks.iPerk == 180)
	{
		if(kUnit.GetCharacter().HasUpgrade(180))
		{
			StrValue1(m_perkNames[m_arrHitBonusPerks.iPerk]);
			IntValue0(m_arrHitBonusPerks.iValue);
		}
	}
*/
	if(m_arrHitBonusPerks.iPerk == 190)
	{
		if(kUnit.GetCharacter().HasUpgrade(190) && kAbility.GetPrimaryTarget().IsVulnerableToElectropulse())
		{
			StrValue1(m_perkNames[m_arrHitBonusPerks.iPerk]);
			IntValue0(m_arrHitBonusPerks.iValue);
		}
	}

	iCounter++;
	if(iCounter > m_arrHitBonusPerks.Length)
	{
		StrValue0("False");
	}
}

function HitPenaltyLoop()
{
	local XGAbility_Targeted kAbility;
	local XGUnit kUnit;

	kAbility = XGAbility_Targeted(m_kRPlus.Object());
	kUhit = kAbility.m_kUnit;
/*
	if(m_arrHitPenaltyPerks.iPerk == 179)
	{
		if(kAbility.GetPrimaryTarget().GetCharacter().HasUpgrade(179))
		{
			StrValue1(m_perkNames[m_arrHitPenaltyPerks.iPerk]);
			IntValue0(m_arrHitPenaltyPerks.iValue);
		}
	}
*/
	iCounter++;
	if(iCounter > m_arrHitPenaltyPerks.Length)
	{
		StrValue0("False");
	}
}

function ApplyPsiEffects()
{
	local XGUnit kTarget;

	kTarget = XGAction_Fire(XGUnit(m_kRPlus.Object()).m_kCurrentAction).m_kTargetedEnemy;

	if(kTarget.GetCharacter().HasUpgrade(189))
	{
		CorruptMessage();
	}
}

// Messages that appears to let the player know if Corrupt failed or succeeded
function CorruptMessage()
{
	local XGUnit kTarget;
	local bool bPanic;
	local XComUIBroadcastWorldMessage kMessage;
	local string msgStr;
	local int CorruptWillTest, WillChance, UnitWill;

	kTarget = XGAction_Fire(XGUnit(m_kRPlus.Object()).m_kCurrentAction).m_kTargetedEnemy;

	CorruptWillTest = (25 + ((kTarget.RecordMoraleLoss(6) / 4) * XGCharacter_Soldier(kTarget.GetCharacter()).m_kSoldier.iRank));
	UnitWill = m_kUnit.RecordMoraleLoss(7);
	WillChance = m_kUnit.WillTestChance(CorruptWillTest, UnitWill, false, false,, 50);

	LogInternal("CorruptWillTest= " $ string(CorruptWillTest) @ "//" @ "UnitWill= " $ string(UnitWill) @ "//" @ "WillChance= " $ string(WillChance), 'CorruptMessage');

	if(m_kUnit != none && kTarget != none && XGCharacter_Soldier(kTarget.GetCharacter()) != none)
	{
		bPanic = m_kUnit.PerformPanicTest(CorruptWillTest,, true, 8);

		if(bPanic)
		{
			msgStr = left(split(Class'XGTacticalGameCore'.default.m_aExpandedLocalizedStrings[6], "("), inStr(split(Class'XGTacticalGameCore'.default.m_aExpandedLocalizedStrings[6], "("), ")") + 1);
		}
		else
		{
			msgStr = left(split(Class'XGTacticalGameCore'.default.m_aExpandedLocalizedStrings[4], "("), inStr(split(Class'XGTacticalGameCore'.default.m_aExpandedLocalizedStrings[4], "("), ")") + 1);
		}

		XComTacticalGRI(WORLDINFO().GRI).m_kBattle.m_kDesc.m_iDifficulty = 0;

		kMessage = XComPresentationLayer(XComPlayerController(WORLDINFO().GetALocalPlayerController()).m_Pres).GetWorldMessenger().Message(PERKS().m_arrPerks[189].strName[0] @ string(100 - WillChance) $ "%" @ msgStr, kTarget.GetLocation(), bPanic ? 3 : 4,,, kTarget.m_eTeamVisibilityFlags,,,, Class'XComUIBroadcastWorldMessage_UnexpandedLocalizedString');

		if(kMessage != none)
		{
			XComUIBroadcastWorldMessage_UnexpandedLocalizedString(kMessage).Init_UnexpandedLocalizedString(0, kTarget.GetLocation(), bPanic ? 3 : 4, kTarget.m_eTeamVisibilityFlags);
		}

		XComTacticalGRI(WORLDINFO().GRI).m_kBattle.m_kDesc.m_iDifficulty = XComGameReplicationInfo(WORLDINFO().GRI).m_kGameCore.m_iDifficulty;
	}
}