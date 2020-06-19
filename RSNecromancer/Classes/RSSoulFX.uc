//=============================================================================
// RSSoulFX.
//=============================================================================
class RSSoulFX expands RuneSpheres;

var float ElapsedTime;
var float MaxDeviation;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	VelocityMax = -(vector(Rotation) * 75);
}

// init function
simulated function SystemInit()
{
	local int i;
	local float f;

	ElapsedTime = RandRange(0.0, 5.0);
	for (i=0; i<8; i++)
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
	local float d; //Distance
	local int MaxDeviation;
	
	d = 1;
	MaxDeviation = 4;
	ElapsedTime += DeltaTime;
	
	for (i=0; i<5; i++)
	{		
		
			ParticleArray[i].Location = Location +
			(vect(1,0,0) * Sin(ElapsedTime*(i+d)) * MaxDeviation*i) +
			(vect(0,1,0) * Cos(ElapsedTime*(i+d)) * MaxDeviation*i) +
			(vect(0,0,1) * Tan(ElapsedTime*i)) ;
	
	
		//	slog(ParticleArray[i].Location);
	}
}

defaultproperties
{
     ParticleTexture(0)=Texture'RuneFX.SparkBlue'
     ScaleDeltaX=0.700000
     ScaleDeltaY=0.700000
     PercentOffset=1
}
