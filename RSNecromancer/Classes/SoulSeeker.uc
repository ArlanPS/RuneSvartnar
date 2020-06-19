//=============================================================================
// SoulSeeker.
//=============================================================================
class SoulSeeker expands Seeker;
// Importing sound for Skelemancer Soul Seeker

var Pawn TargetPawn;
var ParticleSystem Trail;
var() float ConvergeFactor;
var float TimeToDamage;

simulated function PreBeginPlay()
{
	local vector X,Y,Z;
	local int s;
	
	Trail = Spawn(class'SkelemancerSoul2'); //better than SkelemancerSoul3
	Trail.SetBase(self);

	GetAxes(Rotation,X,Y,Z);
	Velocity = X * Speed;
	
	s = rand(5);

	if (s == 0)
	{
	    Default.AmbientSound = Sound'RSNecromancer.SkelemancerSoul.SkelemancerSoulFX0';
	}
	else if (s == 1)
	{
	    Default.AmbientSound = Sound'RSNecromancer.SkelemancerSoul.SkelemancerSoulFX1'; 
	}
	else if (s == 2)
	{
	    Default.AmbientSound = Sound'RSNecromancer.SkelemancerSoul.SkelemancerSoulFX2'; 
	}
	else if (s == 3)
	{
	   Default.AmbientSound = Sound'RSNecromancer.SkelemancerSoul.SkelemancerSoulFX3'; 
	}
	else if (s == 4)
	{
	    Default.AmbientSound = Sound'RSNecromancer.SkelemancerSoul.SkelemancerSoulFX4'; 
	}
	else
	{
	   Default.AmbientSound = Sound'RSNecromancer.SkelemancerSoul.SkelemancerSoulFX5'; 
	}
	
	Default.SoundRadius = 50;
	Default.SoundVolume = 240;
	Default.TransientSoundRadius = 1;
	Default.TransientSoundVolume = 2;

}


simulated function Destroyed()
{
	Spawn(Class'SkelemancerSummonFX');
	Trail.Destroy();
}

simulated function Tick(float DeltaTime)
{
	local vector Dir;
	local PlayerPawn aPawn;
	local float dist, bestdist;

	Super.Tick(DeltaTime);
	
	if (TargetPawn==None || TargetPawn.Health<=0)
	{	// Find a new target
		bestdist = 1000000;
		TargetPawn = None;
		foreach VisibleCollidingActors(class'PlayerPawn', aPawn, 1000)
		{
			dist = VSize(aPawn.Location-Location);
			if (aPawn != Instigator && aPawn.Health > 0 && dist < bestdist && aPawn.bProjTarget)
			{	// Target this pawn
				TargetPawn = aPawn;
				bestdist = dist;
			}
		}
	}
	else
	{
		Dir = Normal( Normal(Velocity) + DeltaTime * ConvergeFactor * Normal(TargetPawn.Location-Location) );
		Velocity = Dir * MaxSpeed;
	}
	
	// Code to not allow the seeker to damage constantly while it is touching an actor

	TimeToDamage -= DeltaTime;
}

simulated function HitWall(vector HitNormal, actor Wall)
{
	return; //Explode(Location, HitNormal);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
		if(Other.IsA('Weapon'))
		return;
		
	//	Other.JointDamaged(Damage, Pawn(Owner), HitLocation, Velocity * 0.5, 'fire', 0);
		Other.JointDamaged(Damage, Instigator, HitLocation, Velocity, 'fire', 0);
		TimeToDamage = 1.0; // Only damage every second
		ConvergeFactor = 10.000000;

}

simulated function Landed(vector HitNormal, actor HitActor)
{
	Explode(Location, HitNormal);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	
	// just a effect to looks like the souls has evaporated and not just gone
	//Spawn(Class'SkelemancerSummonFX');
	spawn(class'SkelemancerSummonFX',self, , HitLocation, rotator(HitNormal));
	Destroy();
}

defaultproperties
{
     MyDamageType=Blunt
     LifeSpan=5.000000
     SoundRadius=50
     SoundVolume=240
     AmbientSound=Sound'RSNecromancer.SkelemancerSoul.SkelemancerSoulFX0'
     TransientSoundVolume=2.000000
     TransientSoundRadius=1.000000
}
