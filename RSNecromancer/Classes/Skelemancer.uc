//=============================================================================
// Skelemancer.
//=============================================================================
class Skelemancer expands Skeleton;

#exec AUDIO IMPORT NAME=SkelemancerSoulFX0 FILE=Sounds\SkelemancerSoulFX0.wav GROUP="SkelemancerSoul"
#exec AUDIO IMPORT NAME=SkelemancerSoulFX1 FILE=Sounds\SkelemancerSoulFX1.wav GROUP="SkelemancerSoul"
#exec AUDIO IMPORT NAME=SkelemancerSoulFX2 FILE=Sounds\SkelemancerSoulFX2.wav GROUP="SkelemancerSoul"
#exec AUDIO IMPORT NAME=SkelemancerSoulFX3 FILE=Sounds\SkelemancerSoulFX3.wav GROUP="SkelemancerSoul"
#exec AUDIO IMPORT NAME=SkelemancerSoulFX4 FILE=Sounds\SkelemancerSoulFX4.wav GROUP="SkelemancerSoul"
#exec AUDIO IMPORT NAME=SkelemancerSoulFX5 FILE=Sounds\SkelemancerSoulFX5.wav GROUP="SkelemancerSoul"
#exec TEXTURE IMPORT NAME=SkelemancerSoul FILE=Textures\SkelemancerSoul.bmp GROUP="SkelemancerSoul" MIPS=OFF FLAGS=2

//#exec MESH IMPORT MESH=Duke ANIVFILE=MODELS\Duke_a.3d DATAFILE=MODELS\Duke_d.3d X=0 Y=0 Z=0 LODSTYLE=1

//#exec SKELETAL IMPORT NAME=Custom FILE=Meshes\Custom.scm
//#exec SKELETAL ORIGIN NAME=Custom X=0 Y=0 Z=-4 Pitch=0 Yaw=-64 Roll=-64

// Importing sound for Skelemancer Soul Seeker
//#exec AUDIO IMPORT NAME=SkelemancerSS FILE=Sounds\SkelemancerSS.WAV GROUP=RSNecromancer
//exec TEXTURE IMPORT NAME="SkelemancerSoul" FILE="Textures\SkelemancerSoul.bmp"

var GroundHammerEffect Teste;

//============================================================
//
// PostBeginPlay
//
//============================================================
function PostBeginPlay()
{
	local actor A,B,C, D;
	local GroundHammerEffect PC;
	local byte w; // using for randomize a weapon
	local byte s; // using for randomize a shield
	
	Super.PostBeginPlay();

//	A = Spawn(Class'SkelemancerSoul3');
//	AttachActorToJoint(A, JointNamed('jaw'));

	B = Spawn(Class'SkelemancerSoul3');
	AttachActorToJoint(B, JointNamed('chest'));
	
	//Simulate his heart
	C = Spawn(Class'SkelemancerSoul');
	AttachActorToJoint(C, JointNamed('jaw'));
	
	Default.StartStowWeapon = none; // Removing weapons

	w = Rand(5); //Generate a random number between 0 and 5 for dynamic weapong
	s = Rand(2); //Generate a random number between 0 and 2 for dynamic shield
	if (w == 0)     {Default.StartWeapon =  Class'RuneI.VikingBroadSword'; StartWeapon.Default.Style=STY_Translucent;}
	else if (w == 1){Default.StartWeapon = Class 'RuneI.VikingAxe'; StartWeapon.Default.Style=STY_Translucent; }
	else if (w == 2){Default.StartWeapon = Class 'RuneI.handaxe';StartWeapon.Default.Style=STY_Translucent;}
	else if (w == 3){Default.StartWeapon = Class 'RuneI.Torch';StartWeapon.Default.Style=STY_Translucent;}
    else if (w == 4){Default.StartWeapon = Class 'RuneI.RustyMace';StartWeapon.Default.Style=STY_Translucent;}
	else            {Default.StartWeapon = Class 'RuneI.VikingShortSword';StartWeapon.Default.Style=STY_Translucent;}

	//Random Shield
	if(s == 0) {  Default.StartShield = Class 'RuneI.VikingShield'; StartShield.Default.Style=STY_Translucent; }
    else if (s == 1) {  Default.StartShield = Class 'RuneI.VikingShield2'; StartShield.Default.Style=STY_Translucent; }
    else {  Default.StartShield = Class 'RuneI.DarkShield'; StartShield.Default.Style=STY_Translucent; }

}

//================================================
// AttitudeToCreature
//================================================
function eAttitude AttitudeToCreature(Pawn p)
{

	if (p.IsA('Skeleton') || p.IsA('Skelemancer') || p.IsA('Necromancer') || p.IsA('Snowbeast'))
		return ATTITUDE_Friendly;
	else
		return ATTITUDE_Hate;
   // return Super.AttitudeToCreature(Other);
}

//Assombro
function DoHaunt()
{
		local Projectile s;
		local vector FireLocation;
		local bool bfired;

		//SPAWN A BLUE FIRE
		Spawn(Class'SkelemancerSummonFX');
	
		//NOW LETS SUMMON A BLUE SEEKER, THAT WILL LOOKS LIKE A SOUL LEAVING THE BONES
		FireLocation = GetJointPos(JointNamed('head'));
		s = Spawn(class'SoulSeeker', self,,FireLocation,rotator(Normal(Enemy.Location - FireLocation)));
		s.SetPhysics(PHYS_Projectile);
		s.Velocity = Normal(Enemy.Location - FireLocation) * s.Speed;
		slog("Haunt");
}

//============================================================
//
// SkeletonSmash.
//
// Smashes the skeleton up during his death.
//============================================================
function SkeletonSmash(vector Momentum, vector HitLoc)
{
	local int i, joint;
	local vector pos;
	local rotator aRot;
	local Actor part;
	local int distance;
	
	bHidden = true;
	
	if(BodyPartHealth[BODYPART_HEAD] > 0)
	{
		pos = GetJointPos(JointNamed('Head'));
		part = Spawn(Class'SkeletonHead',,, pos, Rotation);
		if(part != None)
		{
			part.Velocity = 0.75 * (Momentum / Mass) + vect(0, 0, 150);
			part.GotoState('Drop');
		}
	}

	if(BodyPartHealth[BODYPART_LARM1] > 0)
	{
		pos = GetJointPos(JointNamed('lshouldb'));
		part = Spawn(Class'SkeletonArm',,, pos, Rotation);
		if(part != None)
		{
			part.Velocity = vect(0.3, 0.3, 0.3) * (FRand() * Momentum);
			part.GotoState('Drop');
		}
	}
	else if(BodyPartHealth[BODYPART_RARM1] > 0)
	{
		pos = GetJointPos(JointNamed('rshouldb'));
		part = Spawn(Class'SkeletonArm',,, pos, Rotation);
		if(part != None)
		{
			part.Velocity = vect(0.3, 0.3, 0.3) * (FRand() * Momentum);
			part.GotoState('Drop');
		}
	}

	pos = GetJointPos(JointNamed('Chest'));
	part = Spawn(Class'SkeletonRibs',,, pos, Rotation);
	if(part != None)
	{
		part.Velocity = vect(0.3, 0.3, 0.3) * (FRand() * Momentum);
	}

	//SPAWN A FEW BONES
	for(i = 0; i < 6; i++)
	{
		pos = GetJointPos(i);
		part = Spawn(Class'SkeletonBone',,, pos, RotRand());
		if(part != None)
		{
			part.Velocity = vect(0.3, 0.3, 0.3) * (FRand() * Momentum);
		}
	}
}

//================================================
// #STEATES
//================================================

function DropFrom(vector StartLocation)
{
	Destroy();
}

//------------------------------------------------------------
//
// DropWeapon
//
//------------------------------------------------------------
function DropWeapon()
{
	local vector X,Y,Z;
	local int joint;
	
	if(Weapon == None)
		return;

	if(Weapon.bPoweredUp)
		Weapon.PowerupEnd();

	joint = JointNamed(WeaponJoint);
	if (joint != 0)
	{
	//	DetachActorFromJoint(joint);
		Weapon.Destroy(); // DO NOT DROP THE WEAPON, JUST DESTROY IT
	}
}	

//------------------------------------------------------------
//
// DropShield
//
//------------------------------------------------------------
function DropShield()
{
	local vector X,Y,Z;
	local int joint;
	
	if(Shield == None)
		return;
	
	joint = JointNamed(ShieldJoint);
	if (joint != 0)
	{
	//	DetachActorFromJoint(joint);
		Shield.Destroy(); // DO NOT DROP THE WEAPON, JUST DESTROY IT
	}
}

//================================================
// Dying.
// Overriden since all we want to do is delete the skeleton
//================================================
state Dying
{
ignores SeePlayer, EnemyNotVisible, HearNoise, KilledBy, Trigger, Bump, HitWall, HeadZoneChange, FootZoneChange, ZoneChange, Falling, WarnTarget, Died, LongFall, PainTimer, Landed, EnemyAcquired, CheckForEnemies;

	function BeginState()
	{
	
	 	local int joint;
	 	local vector X, Y, Z;	
	 	local actor eyes;

	 	Super.BeginState();
	 	
	//	StowWeapon = None;
		DoHaunt();
		
 	}
	
	function SpawnBloodSplot()								{}
	function Timer()										{}
	function ReplaceWithCarcass()							{}
	function ExpandCollisionRadius()						{}
	function ShrinkCollisionHeight()						{}
	function ApplyPainToJoint(int joint, vector momentum)	{}

	function bool JointDamaged(int Damage, Pawn EventInstigator, vector HitLoc, vector Momentum, name DamageType, int joint)
	{}

Begin:
//	sleep(2.0);


 StowWeapon.Destroy();
	StowWeapon = None;
	Destroy();
	Destroyed();
	Disintegrate();
}

function Destroyed()
{
	Super.Destroyed();
}

	function Disintegrate()
	{		
		local int i;
		local vector v;
		local rotator r;
		local actor puff;
		
		LifeSpan = 1.0;
		ShadowScale = 0; // Turn off any shadow on the creature

/*		
		for(i = 0; i < Rand(5); i++)
		{
			v = VRand();
			r = Rotator(v);
			puff = Spawn(class'ZombieBreath', self,, Location, r);			
			puff.Velocity = v * 75;
			puff.SetPhysics(PHYS_Projectile);			
		}
*/
	}
	

defaultproperties
{
}
