//=============================================================================
// Alma.
//=============================================================================
class Alma expands Seeker;

var Pawn TargetPawn;
var ParticleSystem Trail;
var() float ConvergeFactor;

var float TimeToDamage;

simulated function PreBeginPlay()
{
	local vector X,Y,Z;

	Trail = Spawn(class'SeekerTrail');
	Trail.SetBase(self);

	GetAxes(Rotation,X,Y,Z);
	Velocity = X * Speed;
}


simulated function Destroyed()
{

}

simulated function Tick(float DeltaTime)
{
	local vector Dir;
	local PlayerPawn aPawn;
	local float dist, bestdist;

	Super.Tick(DeltaTime);

	Dir = Normal( Normal(Velocity) + DeltaTime * ConvergeFactor * Normal(TargetPawn.Location-Location) );
	Velocity = Dir * MaxSpeed;
		
	// Code to not allow the seeker to damage constantly while it is touching an actor
	if(TimeToDamage > 0)
	{
		TimeToDamage -= DeltaTime;
	}
}

simulated function HitWall (vector HitNormal, actor Wall)
{

	return;
	Explode(Location, HitNormal);
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{

	return;
	if(Other.IsA('Weapon'))
		return;
			
	if(TimeToDamage <= 0)
	{
		Other.JointDamaged(Damage, Instigator, HitLocation, Velocity, MyDamageType, 0);
		TimeToDamage = 1.0; // Only damage every second
		ConvergeFactor = 10.000000;
	}
	

	if(Other.IsA('Shield')) // The seeker was blocked
		Explode(Location, vect(0, 0, 1));
}

simulated function Explode(vector HitLocation, vector HitNormal)
{

	return;
	Destroy();
}

defaultproperties
{
}
