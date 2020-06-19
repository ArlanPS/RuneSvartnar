//=============================================================================
// Necromancer.
//=============================================================================
class Necromancer expands Viking;


#exec AUDIO IMPORT NAME=NecromancerFire0 FILE=Sounds\NecromancerFire0.wav GROUP="Necromancer"
#exec AUDIO IMPORT NAME=NecromancerFire1 FILE=Sounds\NecromancerFire1.wav GROUP="Necromancer"

#exec AUDIO IMPORT NAME=NecromancerSummon0 FILE=Sounds\NecromancerSummon0.wav GROUP="Necromancer"
#exec AUDIO IMPORT NAME=NecromancerSummon1 FILE=Sounds\NecromancerSummon1.wav GROUP="Necromancer"
#exec AUDIO IMPORT NAME=NecromancerSummon2 FILE=Sounds\NecromancerSummon2.wav GROUP="Necromancer"

#exec AUDIO IMPORT NAME=NecromancerVoice1 FILE=Sounds\NecromancerVoice1.wav GROUP="Necromancer"
 



const DEFAULT_TWEEN = 0.15;
var string EnemyStr;
var Weapon StowWeapon;
var(AI) class<Weapon> StartStowWeapon; // Startup stow weapon
var(Sounds) sound PaceSound;
var name PreUninterrupedState;
var() name CrucifiedAnim;
var(Sounds) sound JumpSound;
var bool bDisintegrating;
var vector JumpDestination;
var vector DebugJumpApex;
var vector DebugJumpLand;
var(Sounds) Sound FireSound; // SLOT_Misc
var(CONFIGURATION) sound SummonSkelSounds[3];
 

var private int breathcounter; //Used for breathing and PlayAnimAsync

var float AttackRange;		// Longest range for ranged attacks
//============================================================
//
// PostBeginPlay
//
//============================================================
function PostBeginPlay()
{
    local actor A, B, C;

    Super.PostBeginPlay();

    A = Spawn(Class'Skull');
    AttachActorToJoint(A, JointNamed('attach_hammer'));

    C = Spawn(Class'Skull');
    AttachActorToJoint(C, JointNamed('attach_sword'));
    
    B = Spawn(Class 'SeekerTrail');
    AttachActorToJoint(B, JointNamed('Jaw'));

    //B = Spawn(Class'SkelemancerSoul2');
    //AttachActorToJoint(B, JointNamed('lwrist'));

    //C = Spawn(Class'SkelemancerSoul3');
    //	AttachActorToJoint(C, 1);
    
    //AUTO START WITH A BLUE TORCH, I'LL WILL BE A STAFF
     Default.StartWeapon =  Class'RuneI.HelTorch';
     StartWeapon.Default.Style=STY_Translucent;
     
}

//================================================
// AttitudeToCreature
//================================================
function eAttitude AttitudeToCreature(Pawn p)
{

    if (p.IsA('Skeleton') || p.IsA('Skelemancer') || p.IsA('Necromancer') || p.IsA('CharredFiend'))
        return ATTITUDE_Friendly;
    else
        return ATTITUDE_Hate;
    // return Super.AttitudeToCreature(Other);
}

	function DoThrow()
	{

		local Projectile ball;
		local vector FireLocation;
	
		AltWeaponActivate();
     	return;


		FireLocation = GetJointPos(JointNamed('rwrist'));
		ball = Spawn(class'MechRocket', self,,FireLocation,rotator(Normal(Enemy.Location - FireLocation)));
		ball.SetPhysics(PHYS_Projectile);
		ball.Velocity = Normal(Enemy.Location - FireLocation) * ball.Speed;

		PlaySound(FireSound, SLOT_Misc,,,, 1.0 + FRand()*0.4-0.2);
		Slog("Fogo");


}

//================================================
//
// InRange
//
//================================================
function bool InRange(actor Other, float range)
{
	if (Other == None)
		return false;
	return (VSize(Location-Other.Location) < CollisionRadius + Other.CollisionRadius + range);
}

function LifeDrain()
{
    local Projectile ball;
    local vector FireLocation;
    local bool bfired;

    //TODO: Fire out in actual direction dictated by look
    FireLocation = GetJointPos(JointNamed('rwrist'));
    ball = Spawn(class 'MechRocket', self, , FireLocation, rotator(Normal(Enemy.Location - FireLocation)));
    ball.SetPhysics(PHYS_Projectile);
    ball.Velocity = Normal(Enemy.Location - FireLocation) * ball.Speed;
    bfired = true;
}

function PlayFire()
{
   PlayAnim('s2_throw', 1.0, 0.0); // open arms
}


function PlayWaitingAsync()
{
    // DEFAULT
    //LoopAnim('T_OUTIdle', 1.0, DEFAULT_TWEEN);
    local SkelemancerSoul3 a; //used as effect
    local SkelemancerSoul3 b; //used as effect
    local rotator r;
    local vector leftHand;
    local vector rightHand;
    local vector l;
// x3_taunt - abre os bracos
// T_taunt - Joga uma moeda e pega
// x1_taunt - levanta o braco direito
// KnockedOut - Anim for dying.
// x1_throw - Lana uma bola de baseball
// x2_throw - Lana uma bola de baseball
// x1_idle - posicao de guerra, com magia nas maos
// T_standingAttack - Torch, aponta pra frente
// T_Idle = quando estiver com o Cajado

    LoopAnim('neutral_idle', 1.0, DEFAULT_TWEEN);
    //I made this loop based on breath since I want that this animation play every second, like a Loopanim but with some effects.
    //Its a kind of LoopAnim Async, where I play the animation in a loop and do something else at same time.
    if (++breathcounter > 1)
    {
        breathcounter = 0;
        PlayAnim('x3_taunt', 1.0, 0.0); // open arms

        if (Enemy != None)
        {
            r = rotator(Enemy.Location - Location); //look at me
        }
        else
        {
            r = rotator(Location); //look at me
        }

        leftHand = GetJointPos(JointNamed('lwrist'));
        rightHand = GetJointPos(JointNamed('rwrist'));

        a = Spawn(class 'SkelemancerSoul3', self, , leftHand, r);
        a.Velocity = vector(r) * 100;
        a.Velocity = vector(r) * 100;
        a.bSystemOneShot = true;
        a.bOneShot = true;

        b = Spawn(class 'SkelemancerSoul3', self, , rightHand, r);
        b.Velocity = vector(r) * 100;
        b.bSystemOneShot = true;
        b.bOneShot = true;
        // b.SetPhysics(PHYS_Projectile);
    }
    // for(P = Level.PawnList; P != None; P = P.nextPawn)
    // {
    // 	if (p!=None && p.IsA('Skelemancer')){ SandBox(1); break; }
    // }

    //LoopAnim('cine_newTalkA', 1.0, DEFAULT_TWEEN);
    // Attack -> boxe
    // x3_taunt -> abre os braos
    // uscript06_03a -> conversar
    // T_BackupAttack -> aponta pra frente e da um passo pra tras

    // ReactToPullOut -> deitado se tremendo, pode colocar umas almas perto dele.

    // if(Weapon != None)
    // {
    // 	LoopAnim(Weapon.A_Idle, RandRange(0.8, 1.2), 0.2);
    // }
    // else
    // {
    // 	LoopAnim('uscript06_03a', RandRange(0.8, 1.2), 0.2);
    // }
}

function Sandbox(int pos)
{
    // local vector loc;
    // local vector rot;

    // loc = Owner.Location;
    // loc.Z -= Owner.CollisionHeight;

    // 	// front
    // 	if (pos == 0)
    // 	{
    // 		slog("Summon frent 1");
    // 		Spawn(class'Skelemancer', Self,, loc, Rotation);
    // 	};

    // 	// left
    // 	if (pos == 1)
    // 	{
    // 		slog("Summon Esquerda 2");
    // 		Spawn(class'Skelemancer', Self,,rot , Rotation);
    // 	};

    // 	// right
    // 	if (pos == 2)
    // 	{
    // 		slog("Summon Direita 3");
    // 		Spawn(class'Skelemancer', Self,, rot, Rotation);
    // 	};

    local rotator newRot;
    local class<ScriptPawn> SarkClass;
    local ScriptPawn Skelemancer;
    local pawn P;
    local class<RespawnFire> rf;

    Spawn(Class 'SkelemancerSummonFX');

    SetCollision(false, false, false);
    newRot = Owner.Rotation;
    newRot.Yaw += (3000 * pos);
    Skelemancer.Velocity = vector(Owner.Rotation) * (450 + FRand() * 100);
    Skelemancer = Spawn(class 'Skelemancer', , , Location, newRot);

    if (Skelemancer != None)
    {
        Skelemancer.Event = Event;
        Skelemancer.Tag = Tag;
        for (P = Level.PawnList; P != None; P = P.nextPawn)
        {
            if (P.bIsPlayer)
            {
                Skelemancer.LookAt(P);
                break;
            }
        }
        Skelemancer.Orders = 'roaming';
        Skelemancer.OrdersTag = '';
    }
    SetCollision(true, true, true);
}

//NOVO
function AltWeaponActivate()
{
	local actor a;
	local rotator r;
	local vector l;
	local byte s;
	
	if(Enemy == None)
		return;
	
	SetCollision(false, false, false);
	// 100 loos totatly fine, its just in front of the necromancer

	
	PlaySound(SummonSkelSounds[0], SLOT_Talk,,,, 1.0 + FRand()*0.2-0.1);
	AmbientSoundTime = (0.5 + FRand()*0.5) * AmbientWaitSoundDelay;
	
	GetOutOfHere();
	
	r = rotator(Enemy.Location - Location);
	l = GetJointPos(JointNamed('head')) + vector(r) * 100; 
	Spawn(class'RespawnFire', self,, l, r);
	Spawn(class'Skelemancer', self,, l, r);
	
	r = rotator(Enemy.Location - Location);
	r.Yaw = -3000;
	l = GetJointPos(JointNamed('head')) + vector(r) * -100;
	Spawn(class'RespawnFire', self,, l, r);
	Spawn(class'Skelemancer', self,, l, r);
	
	
	r = rotator(Enemy.Location - Location);
	r.Yaw = 3000;
	l = GetJointPos(JointNamed('head')) + vector(r) * 100;
	Spawn(class'RespawnFire', self,, l, r);
	Spawn(class'Skelemancer', self,, l, r);
	
	
	r = rotator(Enemy.Location - Location);
	r.Yaw = -3000;
	l = GetJointPos(JointNamed('head')) + vector(r) * 100;
	Spawn(class'RespawnFire', self,, l, r);
	Spawn(class'Skelemancer', self,, l, r);


	SetCollision(true, true, true);
}

//=============================================================================
//	USED TO SHAKE THE VIEW WHEN THE KEG EXPLODE
//=============================================================================

//=============================================================================
//	USED SUMMON A BONEBEAST, A KIND OF SNOWBEAST
//=============================================================================
function SummonBoneBeast()
{
	local actor a;
	local rotator r;
	local vector l;
	local float QuakeTime;
    local float QuakeMagnitude;
    local float QuakeRadius;
    local byte QuakeFalloff;
  
    
    if(Enemy == None) return;

    //setting up
    QuakeTime = 4;
    QuakeMagnitude=500;
    QuakeRadius=2000;
    QuakeFalloff=2;

	SetCollision(false, false, false);

	PlaySound(SummonSkelSounds[1], SLOT_Talk,,,, 1.0 + FRand()*0.2-0.1);
	AmbientSoundTime = (0.5 + FRand()*0.5) * AmbientWaitSoundDelay;
	
	r = rotator(Enemy.Location - Location);
	l = GetJointPos(JointNamed('head')) + vector(r) * 200; 
	Spawn(class'RespawnFire', self,, l, r);
	Spawn(class'BoneBeast', self,, l, r);

	SetCollision(true, true, true);
}

 
function GetOutOfHere()
{
	local BlastRadius B;
	local vector loc;

	loc = Owner.Location - vect(0, 0, 10);
	B = Spawn(class'BlastRadius',,, loc, rotator(vect(0,0,1)));
	//B.Instigator = Pawn(Owner);
	slog("Aqui");
}

function SpawnSark()
{
    local rotator newRot;
    local class<ScriptPawn> SarkClass;
    local ScriptPawn Skelemancer;
    local pawn P;
    local class<RespawnFire> rf;

    Spawn(Class 'SkelemancerSummonFX');

    //	Spawn(Class'DebrisCloud');
    SetCollision(false, false, false);
    newRot = Rotation * -1;
    Skelemancer = Spawn(class 'Skelemancer', , , Location, newRot);

    if (Skelemancer != None)
    {
        Skelemancer.Event = Event; // Carry over death event
        Skelemancer.Tag = Tag;

        for (P = Level.PawnList; P != None; P = P.nextPawn)
        {
            if (P.bIsPlayer)
            {
                Skelemancer.LookAt(P);
                break;
            }
        }
        Skelemancer.Orders = 'roaming';
        Skelemancer.OrdersTag = '';
    }

    SetCollision(true, true, true);
}

function PlayFlip(optional float tween)
{
   // PlayAnim('S3_taunt', 1.0, tween);
    PlayAnim('T_lite',1.0,0.0); //Point to sky and fly
    Spawn(class'ManowarRipple');
}

auto State Startup
{
    //============================================================
    // SpawnStartInventory
    //============================================================
    function SpawnStartInventory()
    {
        Super.SpawnStartInventory();

        bStopMoveIfCombatRange = true;

        if (StartStowWeapon != None && StartStowWeapon.Default.MeleeType != MELEE_NON_STOW)
        {
            if (StartWeapon != None)
            {
                if (StartWeapon.Default.MeleeType == StartStowWeapon.Default.MeleeType)
                { // The start weapon and stow weapon are of the same class, don't spawn the stow weapon
                    return;
                }
            }
            StowWeapon = Spawn(StartStowWeapon, self);
        }
    }

    //============================================================
    // TouchSurroundingObjects
    //============================================================

    function TouchSurroundingObjects()
    {
        if (StowWeapon != None)
        {
            AddInventory(StowWeapon);

            switch (StowWeapon.MeleeType)
            {
            case MELEE_SWORD:
                AttachActorToJoint(StowWeapon, JointNamed('attatch_sword'));
                break;
            case MELEE_AXE:
                AttachActorToJoint(StowWeapon, JointNamed('attach_axe'));
                break;
            case MELEE_AXE:
                AttachActorToJoint(StowWeapon, JointNamed('attach_hammer'));
                break;
            default:
                // Unknown or non-stow item
                StowWeapon.Destroy();
            }

            StowWeapon.GotoState('Stow');
        }

        Super.TouchSurroundingObjects();
    }
}

//------------------------------------------------
//
// Breath
//
//------------------------------------------------
function Breath()
{
    local int joint;
    local vector l;

    if (++breathcounter > 1)
    {
        breathcounter = 0;
        OpenMouth(0.5, 0.5);

        if (HeadRegion.Zone.bWaterZone)
        {
            // Spawn Bubbles
            joint = JointNamed('jaw');
            if (joint != 0)
            {
                l = GetJointPos(joint);
                if (FRand() < 0.3)
                {
                    Spawn(class 'BubbleSystemOneShot', , , l, );
                }
            }
        }
        else
        {
            PlaySound(BreathSound, SLOT_Interface, , , , 1.0 + FRand() * 0.2 - 0.1);
        }
    }
    else
    {
        OpenMouth(0.0, 0.3);
    }
}

//============================================================
//
// BodyPartForJoint
//
// Returns the body part a joint is associated with
//============================================================
function int BodyPartForJoint(int joint)
{
    switch (joint)
    {
    case 24:
        return BODYPART_LARM1;
    case 31:
        return BODYPART_RARM1;
    case 6:
    case 7:
        return BODYPART_RLEG1;
    case 2:
    case 3:
        return BODYPART_LLEG1;
    case 17:
        return BODYPART_HEAD;
    case 11:
        return BODYPART_TORSO;
    default:
        return BODYPART_BODY;
    }
}

//============================================================
//
// BodyPartForPolyGroup
//
//============================================================
function int BodyPartForPolyGroup(int polygroup)
{
    return BODYPART_BODY;
}

//============================================================
//
// BodyPartSeverable
//
//============================================================
function bool BodyPartSeverable(int BodyPart)
{
    switch (BodyPart)
    {
    case BODYPART_HEAD:
    case BODYPART_LARM1:
    case BODYPART_RARM1:
        return true;
    }
    return false;
}

//============================================================
//
// BodyPartCritical
//
//============================================================
function bool BodyPartCritical(int BodyPart)
{
    return (BodyPart == BODYPART_HEAD);
}

//============================================================
//
// ApplyGoreCap
//
//============================================================
function ApplyGoreCap(int BodyPart)
{
}

//================================================
//
// LimbSevered
//
//================================================
function LimbSevered(int BodyPart, vector Momentum)
{
    local int joint;
    local vector X, Y, Z, pos;
    local actor part;
    local class<actor> partclass;

    Super.LimbSevered(BodyPart, Momentum);

    ApplyGoreCap(BodyPart);
    partclass = SeveredLimbClass(BodyPart);

    part = None;
    switch (BodyPart)
    {
    case BODYPART_HEAD:
        joint = JointNamed('head');
        pos = GetJointPos(joint);
        part = Spawn(partclass, , , pos, Rotation);
        if (part != None)
        {
            part.Velocity = 0.75 * (momentum / Mass) + vect(0, 0, 300);
            part.GotoState('Drop');
        }
        part = Spawn(class 'BloodSpurt', self, , pos, Rotation);
        if (part != None)
        {
            AttachActorToJoint(part, joint);
        }
        break;
    case BODYPART_LARM1:
        joint = JointNamed('lshoulda');
        pos = GetJointPos(joint);
        part = Spawn(partclass, , , pos, Rotation);
        if (part != None)
        {
            part.Velocity = Y * 100 + vect(0, 0, 175);
            part.GotoState('Drop');
        }
        part = Spawn(class 'BloodSpurt', self, , pos, Rotation);
        if (part != None)
        {
            AttachActorToJoint(part, joint);
        }
        break;
    case BODYPART_RARM1:
        joint = JointNamed('rshoulda');
        pos = GetJointPos(joint);
        part = Spawn(partclass, , , pos, Rotation);
        if (part != None)
        {
            part.Velocity = Y * 100 + vect(0, 0, 175);
            part.GotoState('Drop');
        }
        part = Spawn(class 'BloodSpurt', self, , pos, Rotation);
        if (part != None)
        {
            AttachActorToJoint(part, joint);
        }
        break;
    }
}

//------------------------------------------------------------
//
// MakeTwitchable
//
// TODO: Move to carcass
//------------------------------------------------------------
function MakeTwitchable()
{
    local int j;

    // Turn all collision joints accelerative
    for (j = 0; j < NumJoints(); j++)
    {
        if ((JointFlags[j] & JOINT_FLAG_COLLISION) == 0)
            continue;

        switch (j)
        {
        case 11:
        case 2:
        case 6:
            break;
        default:
            JointFlags[j] = JointFlags[j] | JOINT_FLAG_ACCELERATIVE;
            //				SetJointRotThreshold(j, 16000);
            //				SetJointDampFactor(j, 0.025);
            //				SetAccelMagnitude(j, 8000);
            break;
        }
    }
}

//============================================================
//
// CanPickup
//
// Let's pawn dictate what it can pick up
//============================================================
function bool CanPickup(Inventory item)
{
    if (Health <= 0)
        return false;

    if (item.IsA('Weapon') && (BodyPartHealth[BODYPART_RARM1] > 0) && (Weapon == None))
    {
        return (item.IsA('axe') || item.IsA('hammer') || item.IsA('Sword') || item.IsA('Torch'));
    }
    else if (item.IsA('Shield') && (BodyPartHealth[BODYPART_LARM1] > 0) && (Shield == None))
    {
        return item.IsA('Shield');
    }
    return (false);
}

//============================================================
//
// InCombatRange
//
//============================================================

function bool InCombatRange(Actor Other)
{
    if (Other == None)
        return (false);

    return (VSize(Location - Other.Location) < CollisionRadius + Other.CollisionRadius + CombatRange);
}

//============================================================
// Animation functions
//============================================================

function PlayWaiting(optional float tween)
{
    // LoopAnim('x3_taunt', 1.0, 0.0); // open arms
    PlayWaitingAsync();

    // if(Weapon != None)
    // {
    // 	LoopAnim(Weapon.A_Idle, RandRange(0.8, 1.2), 0.2);
    // }
    // else
    // {
    // 	LoopAnim('neutral_idle', RandRange(0.8, 1.2), 0.2);
    // }
}

//============================================================
//
// PlayMoving
//
//============================================================

function PlayMoving(optional float tween)
{
    if (Weapon == None)
        LoopAnim('MOV_ALL_run1_AA0N', 1.0, DEFAULT_TWEEN);
    else
        LoopAnim(Weapon.A_Forward, 1.0, DEFAULT_TWEEN);
}

//============================================================
//
// PlayStrafeLeft
//
//============================================================

function PlayStrafeLeft(optional float tween)
{
    if (Weapon == None)
        LoopAnim('MOV_ALL_lstrafe1_AN0N', 1.0, DEFAULT_TWEEN);
    else
        LoopAnim(Weapon.A_StrafeLeft, 1.0, DEFAULT_TWEEN);
}

//============================================================
//
// PlayStrafeRight
//
//============================================================

function PlayStrafeRight(optional float tween)
{
    if (Weapon == None)
        LoopAnim('MOV_ALL_rstrafe1_AN0N', 1.0, DEFAULT_TWEEN);
    else
        LoopAnim(Weapon.A_StrafeRight, 1.0, DEFAULT_TWEEN);
}

//============================================================
//
// PlayBackup
//
//============================================================

function PlayBackup(optional float tween)
{
    if (Weapon == None)
        LoopAnim('MOV_ALL_runback1_AA0S', 1.0, DEFAULT_TWEEN);
    else
        LoopAnim(Weapon.A_Backward, 1.0, DEFAULT_TWEEN);
}

function PlayJumping(optional float tween) { PlayAnim('MOV_ALL_jump1_AA0S', 1.0, tween); }

function PlayMeleeHigh(optional float tween)
{
    if (Weapon != None)
    {
        PlayAnim(Weapon.A_AttackA, 1.0, tween);
    }
}
function PlayMeleeLow(optional float tween)
{
    if (Weapon == None)
        PlayAnim('swipe', 1.0, tween);
    else
        PlayAnim('attackb', 1.0, tween);
}

function PlayTurning(optional float tween)
{
    if (Weapon != None)
        LoopAnim(Weapon.A_Idle, 1.0, tween);
    else
        LoopAnim('neutral_idle', 1.0, tween);
}

function PlayThrowing(optional float tween) { PlayAnim('throwA', 1.0, tween); }
function PlayTaunting(optional float tween) { PlayAnim('s3_taunt', 1.0, tween); }
function PlayInAir(optional float tween)
{
    local name anim;

    if (Weapon != None && Weapon.A_Jump != '')
        anim = Weapon.A_Jump;
    else
        anim = 'MOV_ALL_jump1_AA0S';

    PlayAnim(anim, 1.0, 0.1);
}

function PlayBlockHigh(optional float tween) { LoopAnim('blocklow', 1.0, tween); }
function PlayBlockLow(optional float tween) { LoopAnim('blocklow', 1.0, tween); }

// Pains
function PlayFrontHit(float tweentime)
{
    if (Weapon == None)
    { // Neutral anims
        PlayAnim('n_painFront', 1.0, 0.1);
    }
    else
    { // Weapon-specific
        PlayAnim(Weapon.A_PainFront, 1.0, 0.1);
    }
}

function PlayBackHit(float tweentime)
{
    if (Weapon == None)
    { // Neutral anims
        PlayAnim('n_painBack', 1.0, 0.1);
    }
    else
    { // Weapon-specific
        PlayAnim(Weapon.A_PainBack, 1.0, 0.1);
    }
}

function PlayLeftHit(float tweentime) { PlayAnim('S1_painLeft', 1.0, 0.08); }
function PlayRightHit(float tweentime) { PlayAnim('S1_painRight', 1.0, 0.08); }

function PlaySkewerDeath(name DamageType) { PlayAnim('deathb', 1.0, DEFAULT_TWEEN); }
function PlayDeath(name DamageType)
{
    local name anim;

    if (DamageType == 'decapitated')
        PlayAnim('DeathH', 1.0, DEFAULT_TWEEN);
    if (DamageType == 'fire')
        PlayAnim('DeathF', 1.0, DEFAULT_TWEEN);
    else
    { // Normal death, randomly choose one
        anim = 'DTH_ALL_death1_AN0N';

        switch (RandRange(0, 5))
        {
        case 0:
            anim = 'DTH_ALL_death1_AN0N';
            break;
        case 1:
            anim = 'DeathH';
            break;
        case 2:
            anim = 'DeathL';
            break;
        case 3:
            anim = 'DeathB';
            break;
        case 4:
            anim = 'DeathKnockback';
            break;
        default:
            anim = 'DTH_ALL_death1_AN0N';
            break;
        }

        PlayAnim(anim, 1.0, DEFAULT_TWEEN);
    }
}

function PlayBackDeath(name DamageType)
{
    local name anim;

    if (FRand() < 0.25)
        anim = 'DeathH';
    else
        anim = 'DeathFront';

    PlayAnim(anim, 1.0, 0.1);
    if (AnimProxy != None)
        AnimProxy.PlayAnim(anim, 1.0, 0.1);
}

// Tween functions
function TweenToWaiting(float time)
{
    if (Weapon != None)
        TweenAnim(Weapon.A_Idle, time);
    else
        LoopAnim('neutral_idle', time);
}

function TweenToMoving(float time)
{
    if (Weapon != None)
        TweenAnim(Weapon.A_Forward, time);
    else
        TweenAnim('MOV_ALL_run1_AA0N', time);
}

function TweenToTurning(float time)
{ // TODO:  Need turning anims
    if (Weapon != None)
        TweenAnim(Weapon.A_Idle, time);
    else
        TweenAnim('neutral_idle', time);
}

function TweenToJumping(float time) { TweenAnim('MOV_ALL_jump1_AA0S', time); }
function TweenToMeleeHigh(float time)
{
    /*
	if (Weapon==None)							TweenAnim ('swipe',     time);
	else										TweenAnim ('attackb',   time);
*/
}
function TweenToMeleeLow(float time)
{
    /*
	if (Weapon==None)							TweenAnim ('swipe',     time);
	else										TweenAnim ('attackb',   time);
*/
}
function TweenToThrowing(float time) { TweenAnim('throwA', time); }

//===================================================================
//
// DoStow
//
// DoStow Notify
//===================================================================

function DoStow()
{
    if (Weapon != None && Weapon.MeleeType == MELEE_NON_STOW)
    { // Drop the weapon
        DropWeapon();
        Weapon = None;
        return;
    }

    Weapon = StowWeapon;

    switch (Weapon.MeleeType)
    {
    case MELEE_SWORD:
        DetachActorFromJoint(JointNamed('attatch_sword'));
        break;
    case MELEE_AXE:
        DetachActorFromJoint(JointNamed('attach_axe'));
        break;
    case MELEE_AXE:
        DetachActorFromJoint(JointNamed('attach_hammer'));
        break;
    case MELEE_NON_STOW:
        DropWeapon();
        break;
    }

    AttachActorToJoint(Weapon, JointNamed(WeaponJoint));
    Weapon.GotoState('Active');
    StowWeapon = None;
}

//===================================================================
//					#States
//===================================================================

//================================================
// Fighting
//================================================
State Fighting
{
	
    ignores EnemyAcquired;

    function BeginState()
    {
        bAvoidLedges = true;
        LookAt(Enemy);
        SetTimer(0.1, true);
    }

    function EndState()
    {
        bAvoidLedges = false;

        bSwingingHigh = false;
        bSwingingLow = false;

        if (Weapon != None)
        {
            Weapon.FinishAttack();
            Weapon.DisableSwipeTrail();
        }

        LookAt(None);
        SetTimer(0, false);
    }

    function AmbientSoundTimer()
    {
        PlayAmbientFightSound();
    }

    function bool BlockRatherThanDodge()
    {
        if (Shield == None)
            return false;

        if (EnemyIncidence != INC_FRONT)
            return false;

        return (FRand() < BlockChance);
    }

    function bool CheckStrafeLeft()
    { // Checks if the left strafe move is valid (not going to strafe into a wall)
        local vector HitLocation, HitNormal;
        local vector extent, end;

        extent.X = CollisionRadius;
        extent.Y = CollisionRadius;
        extent.Z = CollisionHeight * 0.5;

        CalcStrafePosition();

        end = Normal(Destination - Location) * 75;

        if (Trace(HitLocation, HitNormal, end, Location, true, extent) == None)
            return (true); // Nothing in the way
        else
            return (false);
    }

    function bool CheckStrafeRight()
    { // Checks if the right strafe move is valid (not going to strafe into a wall)
        local vector HitLocation, HitNormal;
        local vector extent, end;

        extent.X = CollisionRadius;
        extent.Y = CollisionRadius;
        extent.Z = CollisionHeight * 0.5;

        CalcStrafePosition2();

        end = Normal(Destination - Location) * 75;

        if (Trace(HitLocation, HitNormal, end, Location, true, extent) == None)
            return (true); // Nothing in the way
        else
            return (false);
    }

    // Determine AttackAction based upon enemy movement and position
    function Timer()
    {
        GetEnemyProximity();

        LastAction = AttackAction;

        if (EnemyMovement == MOVE_STRAFE_LEFT && FRand() < 0.7 && CheckStrafeLeft())
        {
            AttackAction = AA_STRAFE_LEFT;
        }
        else if (EnemyMovement == MOVE_STRAFE_RIGHT && FRand() < 0.7 && CheckStrafeRight())
        {
            AttackAction = AA_STRAFE_RIGHT;
        }
        else if (FRand() < 0.2 && Physics == PHYS_Walking && CheckJumpLocation())
        {
            AttackAction = AA_JUMP;
        }
        else if (EnemyMovement == MOVE_STANDING && FRand() < 0.85)
        {
            AttackAction = AA_LUNGE;
        }
        else if (FRand() < 0.75)
        {
            if (FRand() < 0.5 && LastAction != AA_STRAFE_RIGHT || LastAction == AA_STRAFE_LEFT && CheckStrafeLeft())
            {
                AttackAction = AA_STRAFE_LEFT;
            }
            else if (LastAction != AA_STRAFE_LEFT || LastAction == AA_STRAFE_RIGHT && CheckStrafeRight())
            {
                AttackAction = AA_STRAFE_RIGHT;
            }
            else
            {
                AttackAction = AA_WAIT;
            }
        }
        else
        {
            AttackAction = AA_WAIT;
        }
    }

    function bool ShouldDefend()
    {
        return (FRand() > FightOrDefend && InDangerFromAttack());
    }

    function bool InDangerFromAttack()
    {
        if ((!Enemy.bSwingingHigh) && (!Enemy.bSwingingLow))
            return false;

        GetEnemyProximity();

        if (EnemyDist > CollisionRadius + Enemy.CollisionRadius + Enemy.MeleeRange)
            return false;

        return (EnemyVertical == VERT_LEVEL && EnemyFacing == FACE_FRONT);
    }

    function CalcStrafePosition()
    {
        local vector V;
        local rotator R;
        local vector temp;

        V = Location - Enemy.Location;
        R = rotator(V);

        R.Yaw += 2000;

        // Strafe using the enemy's XY location, but the viking's location ground plane
        temp = Enemy.Location;
        temp.Z = Location.Z;

        Destination = temp + vector(R) * CombatRange;
    }

    function CalcStrafePosition2()
    {
        local vector V;
        local rotator R;
        local vector temp;

        V = Location - Enemy.Location;
        R = rotator(V);

        R.Yaw -= 2000;

        // Strafe using the enemy's XY location, but the viking's location ground plane
        temp = Enemy.Location;
        temp.Z = Location.Z;

        Destination = temp + vector(R) * CombatRange;
    }

    function CalcJumpVelocity()
    {
        local float traj;
        local vector arcVel;

        traj = 70 * 65536 / 360;

        // JumpDestination is calculated in CheckJumpLocation
        arcVel = CalcArcVelocity(traj, Location, JumpDestination);

        AddVelocity(arcVel);
    }

    function bool CheckJumpLocation()
    {
        local vector start, end;
        local vector extent;
        local vector HitLocation, HitNormal;

        if (Enemy == None)
            return (false);

        extent.X = CollisionRadius;
        extent.Y = CollisionRadius;
        extent.Z = CollisionHeight * 0.5;

        JumpDestination = Enemy.Location - Location;
        JumpDestination.Z = 0;
        JumpDestination = Enemy.Location + Normal(JumpDestination) * 200;

        start = Location;
        end = ((JumpDestination + start) / 2) + vect(0, 0, 280);

        DebugJumpApex = end;
        DebugJumpLand = JumpDestination;

        // Trace to check if the jump is valid
        if (Trace(HitLocation, HitNormal, end, start, true, extent) == None)
        { // Nothing on the way up, check going down
            start = end;
            end = JumpDestination;

            if (Trace(HitLocation, HitNormal, end, start, true, extent) == None)
            { // Nothing on the way back down, check to make sure that the Sark will land on valid ground
                start = JumpDestination;
                end = JumpDestination - vect(0, 0, 100);

                if (Trace(HitLocation, HitNormal, end, start, false) == None)
                { // Not going to land on anything, so don't do the jump
                    return (false);
                }

                // Otherwise, the jump is good!
                return (true);
            }
            DebugJumpLand = HitLocation;
        }

        return (false);
    }

    function RotateSark()
    {
        local rotator rot;
        rot = Rotation;
        rot.Yaw = Rotation.Yaw + 32768;
        SetRotation(rot);
    }

    function DoStow()
    {
        if (Weapon != None && Weapon.MeleeType == MELEE_NON_STOW)
        { // Drop the weapon
            DropWeapon();
            Weapon = None;
            return;
        }

        Weapon = StowWeapon;

        switch (Weapon.MeleeType)
        {
        case MELEE_SWORD:
            DetachActorFromJoint(JointNamed('attatch_sword'));
            break;
        case MELEE_AXE:
            DetachActorFromJoint(JointNamed('attach_axe'));
            break;
        case MELEE_AXE:
            DetachActorFromJoint(JointNamed('attach_hammer'));
            break;
        case MELEE_NON_STOW:
            DropWeapon();
            break;
        }

        AttachActorToJoint(Weapon, JointNamed(WeaponJoint));
        Weapon.GotoState('Active');
        StowWeapon = None;
    }

Begin:
    if (Enemy == None)
        Goto('BackFromSubState');

    Acceleration = vect(0, 0, 0);

    // Turn to face enemy
    DesiredRotation.Yaw = rotator(Enemy.Location - Location).Yaw;

    if (Weapon.MeleeType == MELEE_NON_STOW && StowWeapon != None)
    { // The creature is carrying a non-stow (probably a torch), but
        // has a weapon stowed, ditch the non-stow in favor of the stowed weapon
        PlayAnim('IDL_ALL_drop1_AA0S', 1.0, DEFAULT_TWEEN);
        FinishAnim();
    }

    // If the creature has a weapon stowed, unsheath it before attacking
    if (Weapon == None && StowWeapon != None)
    { // Unsheath the stow weapon
        switch (StowWeapon.MeleeType)
        {
        case MELEE_SWORD:
            PlayAnim('IDL_ALL_sstow1_AA0S', 1.0, DEFAULT_TWEEN);
            break;
        case MELEE_AXE:
            PlayAnim('IDL_ALL_xstow1_AA0S', 1.0, DEFAULT_TWEEN);
            break;
        case MELEE_HAMMER:
            PlayAnim('IDL_ALL_hstow1_AA0S', 1.0, DEFAULT_TWEEN);
            break;
        }

        FinishAnim();
    }

Fight:
    if (!ValidEnemy())
        Goto('BackFromSubState');

    GetEnemyProximity();

    // Attack if close enough
    if (Weapon != None && InMeleeRange(Enemy) || (EnemyMovement == MOVE_CLOSER && EnemyDist < MeleeRange * 2.5))
    {
        if (LastAction != AA_LUNGE && FRand() < 0.2)
        { // Random chance that the creature will dodge
            PlayMoving();
            if (FRand() < 0.7)
            { // Either jump to the side, or back up
                // Back up
                bStopMoveIfCombatRange = false;
                ActivateShield(true);
                PlayBackup();
                StrafeFacing(Location - vector(Rotation) * (CombatRange - EnemyDist), Enemy);
                ActivateShield(false);
                bStopMoveIfCombatRange = true;
            }
            else
            { // Dodge to the side
                bStopMoveIfCombatRange = false;
                ActivateShield(true);
                PlayStrafeRight();
                StrafeFacing(Location + vector(Rotation + rot(0, 16384, 0)) * CombatRange, Enemy);
                ActivateShield(false);
                bStopMoveIfCombatRange = true;
            }
        }
        else
        {
            PlayAnim(Weapon.A_AttackA, 1.3, 0.1);
            Sleep(0.1);
            WeaponActivate();
            Weapon.EnableSwipeTrail();
            FinishAnim();

            if (Weapon.A_AttackB != 'None' && FRand() < 0.5)
            {
                //				ClearSwipeArray();
                PlayAnim(Weapon.A_AttackB, 1.3, 0.01);
                if (Enemy != None)
                    TurnToward(Enemy);
                FinishAnim();

                // B-Return
                WeaponDeactivate();

                if (Weapon.A_AttackBReturn != 'None')
                {
                    PlayAnim(Weapon.A_AttackBReturn, 1.3, 0.1);
                    FinishAnim();
                }
            }
            else
            { // A-Return
                WeaponDeactivate();

                if (Weapon.A_AttackAReturn != 'None')
                {
                    PlayAnim(Weapon.A_AttackAReturn, 1.3, 0.1);
                    FinishAnim();
                }
            }

            Weapon.DisableSwipeTrail();
        }

        Sleep(TimeBetweenAttacks);
    }
    else if (AttackAction == AA_LUNGE)
    { // Random lunge
        PlayMoving();
        bStopMoveIfCombatRange = false;
        MoveTo(Enemy.Location - VecToEnemy * MeleeRange, MovementSpeed);
        bStopMoveIfCombatRange = true;
    }
    else if (AttackAction == AA_STRAFE_LEFT)
    { // Strafe - Position is calculated in Timer, when the strafe is chosen
        PlayStrafeLeft();
        bStopMoveIfCombatRange = false;
        StrafeFacing(Destination, Enemy);
        bStopMoveIfCombatRange = true;
    }
    else if (AttackAction == AA_STRAFE_RIGHT)
    { // Strafe - Position is calculated in Timer, when the strafe is chosen
        PlayStrafeRight();
        bStopMoveIfCombatRange = false;
        StrafeFacing(Destination, Enemy);
        bStopMoveIfCombatRange = true;
    }
    else if (AttackAction == AA_JUMP)
    {
        PlayFlip(0.1);
        Sleep(0.4);
        PlaySound(JumpSound);
        CalcJumpVelocity();
        WaitForLanding();
        RotateSark();
        PlayAnim('sark_land', 1.0, 0.0);

        if (Enemy != None)
        {
            TurnToward(Enemy);
        }

        PlayAnim('PickupGround', 1.0, 0.0); // TOURCH THE GROUND  SwordPullOutLow
        FinishAnim();                       //TO FINISH HIS ANIM PLAY
       

       	if(rand(1) == 1)
       	{
        	PlaySound(Sound'RSNecromancer.Necromancer.NecromancerSummon0');
        }
        else if(rand(1) == 1)
        {
        	PlaySound(Sound'RSNecromancer.Necromancer.NecromancerSummon1');
        }
        else
        {
        	PlaySound(Sound'RSNecromancer.Necromancer.NecromancerSummon2');
        }
        
  
        for (i = 1; i <= 4; i++)
        {
           // SandBox(i);                             // SUMMON A SKELEMANCER
            PlayAnim('T_StandingAttack', 1.0, 0.0); // Attack direction //  h3_attackA
            FinishAnim();                           //FINISH THE ANIMATION, REMOVING SLEEP(1);
        }
    }
    else
    {
		if (Enemy != None) {TurnToward(Enemy);}

		PlayAnim('x1_throw');
	
		
		if(FRand() >= 0.7)
			{SummonBoneBeast();}
		else
			{	DoThrow(); } // Throw Fire
	
		FinishAnim();

        // PlayAnim('x3_taunt', 1.0, 0.0); // open arms
        // sleep(0.3);
        // PlayAnim('WEAPON2_ATTACKA', 1.0, 0.0);
        // //LifeDrain();
        // Sleep(0.3);
    }

    // if (InCombatRange(Enemy))
    // {
    //     Sleep(0.05);
    //     Goto('Begin');
    // }

BackFromSubState:
    GotoState('Charging', 'ResumeFromFighting');
}

 

//============================================================
//
// Died
//
//============================================================

function Died(pawn Killer, name damageType, vector HitLocation)
{
    local actor eyes;

    eyes = DetachActorFromJoint(JointNamed('head'));
    if (eyes != None)
        eyes.Destroy();

    Super.Died(Killer, damageType, HitLocation);
}

//================================================
//
// Dying
//
//================================================

state Dying
{
    function BeginState()
    {
        local int joint;
        local vector X, Y, Z;

        // Drop any stowed weapons
        if (StowWeapon != None)
        {
            switch (StowWeapon.MeleeType)
            {
            case MELEE_SWORD:
                joint = JointNamed('attatch_sword');
                break;
            case MELEE_AXE:
                joint = JointNamed('attach_axe');
                break;
            case MELEE_AXE:
                joint = JointNamed('attach_hammer');
                break;
            default:
                // Unknown or non-stow item
                return;
            }

            DetachActorFromJoint(joint);

            GetAxes(Rotation, X, Y, Z);
            StowWeapon.DropFrom(GetJointPos(joint));

            StowWeapon.SetPhysics(PHYS_Falling);
            StowWeapon.Velocity = Y * 100 + X * 75;
            StowWeapon.Velocity.Z = 50;

            StowWeapon.GotoState('Drop');
            StowWeapon.DisableSwipeTrail();

            StowWeapon = None; // Remove the StowWeapon from the actor
        }
    }

    function FallBack()
    {
        local vector vel;
        local vector X, Y, Z;

        GetAxes(Rotation, X, Y, Z);

        vel = -200 * X + vect(0, 0, 75);
        AddVelocity(vel);
        SetPhysics(PHYS_Falling);
    }

    function Timer()
    {
        FallBack();
    }

    function Disintegrate()
    {
        local int i;
        local vector v;
        local rotator r;
        local actor puff;
        
		Spawn(Class'Crow');
		Spawn(Class'Crow');
		Spawn(Class'Crow');
		Spawn(Class'Crow');

        bDisintegrating = true;
        LifeSpan = 0.6;
        ShadowScale = 0; // Turn off any shadow on the creature
    }

begin:
    PlayDeath('');
    Sleep(0.4);
    SetTimer(0.1, true); //0.25
    Disintegrate();
}

function Bump(Actor Other)
{
    if (Other.IsA('Keg') || Other.IsA('Stool') || Other.IsA('Bucket'))
    { // Vikings will smash kegs that are in the way
        UseActor = Other;

        if (FRand() < 0.2 || Other.Location.Z < Location.Z || Weapon == None)
        {
            PlayUninterruptedAnim(UseActor.GetUseAnim());
        }
        else
        {
            PlayUninterruptedAnim(Weapon.A_AttackA);
        }
    }
    else
    {
        Super.Bump(Other);
    }
}

simulated function Debug(Canvas canvas, int mode)
{
    local vector offset;

    Super.Debug(canvas, mode);

    Canvas.DrawText("Sark:");
    Canvas.CurY -= 8;
    Canvas.DrawText("	PreUninterrupt: " $ PreUninterrupedState);
    Canvas.CurY -= 8;
    Canvas.DrawText("	NextOrder/Tag: " $ NextState @NextLabel);
    Canvas.CurY -= 8;
    Canvas.DrawText("	Enemy String: " $ EnemyStr);
    EnemyStr = "None";

    Canvas.CurY -= 8;
    if (EnemyFacing == FACE_FRONT)
    {
        Canvas.DrawText("	Enemy Facing:  FRONT");
    }
    else if (EnemyFacing == FACE_BACK)
    {
        Canvas.DrawText("	Enemy Facing:  BACK");
    }
    else
    {
        Canvas.DrawText("	Enemy Facing:  SIDE");
    }

    Canvas.CurY -= 8;
    if (EnemyVertical == VERT_ABOVE)
    {
        Canvas.DrawText("	Enemy Vertical:  ABOVE");
    }
    else if (EnemyVertical == VERT_BELOW)
    {
        Canvas.DrawText("	Enemy Vertical:  BELOW");
    }
    else
    {
        Canvas.DrawText("	Enemy Vertical:  LEVEL");
    }

    Canvas.CurY -= 8;
    if (EnemyMovement == MOVE_CLOSER)
    {
        Canvas.DrawText("	Enemy Movement:  CLOSER");
    }
    else if (EnemyMovement == MOVE_FARTHER)
    {
        Canvas.DrawText("	Enemy Movement:  FARTHER");
    }
    else if (EnemyMovement == MOVE_STRAFE_LEFT)
    {
        Canvas.DrawText("	Enemy Movement:  STRAFE_LEFT");
    }
    else if (EnemyMovement == MOVE_STRAFE_RIGHT)
    {
        Canvas.DrawText("	Enemy Movement:  STRAFE_RIGHT");
    }
    else
    {
        Canvas.DrawText("	Enemy Movement:  STANDING");
    }

    Canvas.CurY -= 8;
    Canvas.DrawText("   AttackAction:  " $ AttackAction);

    offset = Destination;
    Canvas.DrawLine3D(offset + vect(10, 0, 0), offset + vect(-10, 0, 0), 255, 0, 0);
    Canvas.DrawLine3D(offset + vect(0, 10, 0), offset + vect(0, -10, 0), 255, 0, 0);
    Canvas.DrawLine3D(offset + vect(0, 0, 10), offset + vect(0, 0, -10), 255, 0, 0);

    offset = DebugJumpApex;
    Canvas.DrawLine3D(offset + vect(10, 0, 0), offset + vect(-10, 0, 0), 0, 255, 0);
    Canvas.DrawLine3D(offset + vect(0, 10, 0), offset + vect(0, -10, 0), 0, 255, 0);
    Canvas.DrawLine3D(offset + vect(0, 0, 10), offset + vect(0, 0, -10), 0, 255, 0);

    offset = DebugJumpLand;
    Canvas.DrawLine3D(offset + vect(10, 0, 0), offset + vect(-10, 0, 0), 255, 255, 0);
    Canvas.DrawLine3D(offset + vect(0, 10, 0), offset + vect(0, -10, 0), 255, 255, 0);
    Canvas.DrawLine3D(offset + vect(0, 0, 10), offset + vect(0, 0, -10), 255, 255, 0);
}

defaultproperties
{
     StartShield=None
     SkelMesh=15
}
