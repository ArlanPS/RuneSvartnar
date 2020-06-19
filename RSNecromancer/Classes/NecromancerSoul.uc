//=============================================================================
// NecromancerSoul.
//=============================================================================
class NecromancerSoul expands RuneSpheres;

var float ElapsedTime;
var float MaxDeviation;
var() int AmountOfSouls;

// init function
simulated function SystemInit()
{
	local int i;
	local float f;

	ElapsedTime = RandRange(0.0, 5.0);
	for (i=0; i<ParticleCount; i++)
	{
		ParticleArray[i].Valid = True;
		ParticleArray[i].Velocity = vect(0,0,0);
		ParticleArray[i].Alpha = vect(1,1,1)*AlphaStart;
		ParticleArray[i].LifeSpan = LifeSpanMin + (LifeSpanMax-LifeSpanMin)*FRand();
		ParticleArray[i].TextureIndex = 0;
		ParticleArray[i].Style = Style;

		if (bRelativeToSystem)
			ParticleArray[i].Location = vect(0,0,0);
		else
			ParticleArray[i].Location = Location;

		// small sparks
		f = 0.25;
		ParticleArray[i].ScaleStartX = f;
		ParticleArray[i].ScaleStartY = f;
		ParticleArray[i].XScale = f;
		ParticleArray[i].YScale = f;
	}

	IsLoaded=true;
}

simulated function Tick(float DeltaTime)
{
	local int i;

	ElapsedTime += DeltaTime;
	for (i=0; i<ParticleCount; i++)
	{
		ParticleArray[i].Location = Location +
			(vect(1,0,0) * Sin(ElapsedTime*(i+0.5)) * MaxDeviation) +
			(vect(0,1,0) * Cos(ElapsedTime*(i+0.5)) * MaxDeviation) +
			(vect(0,0,1) * (Sin(ElapsedTime)+1) * (i*0.05) * MaxDeviation);
	}
}

defaultproperties
{
     AmountOfSouls=8
     ParticleTexture(0)=Texture'RuneFX.SparkBlue'
     AlphaStart=85
     AlphaEnd=0
     bAlphaFade=True
     bApplyGravity=True
     bApplyZoneVelocity=True
     SoundRadius=11
     AmbientSound=Sound'EnvironmentalSnd.Fire.fire03L'
}
