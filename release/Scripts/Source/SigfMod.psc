Scriptname SigfMod extends Quest
{Naruto Takeover: everyone in the valley becomes Naruto, the player joins in, shadow clones and Rasengans fight whatever attacks.}

ActorBase Property SigfNaruto Auto
ActorBase Property SigfKurama Auto
ActorBase Property EncBandit04Melee1HNordM Auto
ActorBase Property EncWolf Auto
Weapon Property SigfKunai Auto
Armor Property SigfOrangeSuit Auto
Armor Property SigfNinjaSandals Auto
Armor Property SigfLeafHeadband Auto
Activator Property SigfRasenganOrb Auto
Activator Property SigfSmokePuff Auto
Explosion Property ExplosionShockMass01 Auto
Explosion Property fakeForceBall1024ByFormula Auto
EffectShader Property SigfKuramaFlame Auto
Sound Property SigfPoof Auto
Sound Property SigfCloneJutsu Auto
Sound Property SigfBelieveIt Auto
Sound Property SigfRasenganCharge Auto
Sound Property SigfRasenganHit Auto
Sound Property SigfRasenganShout Auto
bool Property DemoMode Auto

Actor kurama
Actor[] clones
int cloneCount

Event OnInit()
	if IsRunning()
		RegisterForSingleUpdate(25.0)
	endif
EndEvent

; At home the mod runs by itself, unless the recorded demo is driving.
Event OnUpdate()
	if DemoMode
		return
	endif
	SigfLib.Log("naruto takeover (free play)")
	MakePlayerNaruto()
	Takeover(3500.0, 20)
	ShadowClones(6)
	RegisterForSingleUpdate(40.0)
	Wave(4)
EndEvent

; ---------- effects ----------

; Plays a sound at a reference, or at the player while the reference has no 3D yet.
Function PlayAt(Sound s, ObjectReference at)
	if at && at.Is3DLoaded()
		s.Play(at)
	else
		s.Play(Game.GetPlayer())
	endif
EndFunction

Function Poof(ObjectReference at)
	at.PlaceAtMe(SigfSmokePuff)
	PlayAt(SigfPoof, at)
EndFunction

; ---------- Naruto ----------

Actor Function MakeNaruto(ObjectReference at, float sc = 1.0, bool hidden = false)
	Actor n = at.PlaceAtMe(SigfNaruto, 1, false, hidden) as Actor
	if !n
		SigfLib.Error("MakeNaruto: nothing placed")
		return None
	endif
	Debug.Trace("SIGF_SPAWN naruto")
	if !clones
		clones = new Actor[64]
	endif
	if cloneCount < 64
		clones[cloneCount] = n
		cloneCount += 1
	endif
	n.AddItem(SigfKunai, 1, true)
	n.EquipItem(SigfKunai, false, true)
	n.SetActorValue("Aggression", 1)
	n.SetActorValue("Confidence", 4)
	n.SetRelationshipRank(Game.GetPlayer(), 3)
	if sc != 1.0
		n.SetScale(sc)
	endif
	return n
EndFunction

; Every villager and animal near the player poofs into a Naruto, all at once.
int Function Takeover(float radius = 3500.0, int maxCount = 20, bool nearPlayer = false)
	Actor p = Game.GetPlayer()
	Actor[] olds = new Actor[24]
	Actor[] news = new Actor[24]
	int made = 0
	int tries = 0
	while tries < 20 && made < maxCount && made < 24
		tries += 1
		Actor a = Game.FindRandomActor(p.GetPositionX(), p.GetPositionY(), p.GetPositionZ(), radius)
		if a && a != p && !a.IsDisabled() && !a.IsDead() && a.GetActorBase() != SigfNaruto && a.GetActorBase() != SigfKurama && olds.Find(a) < 0
			olds[made] = a
			if nearPlayer
				; the new Naruto stands in front of the player, the villager's own spot just loses its owner
				ObjectReference m = SigfLib.Front(260.0 + Utility.RandomFloat(0.0, 520.0), Utility.RandomFloat(-360.0, 360.0))
				Poof(m)
				news[made] = MakeNaruto(m, 1.0, true)
				m.Delete()
			else
				Poof(a)
				news[made] = MakeNaruto(a, 1.0, true)
			endif
			made += 1
		endif
	endwhile
	Utility.Wait(0.4)
	int i = 0
	while i < made
		news[i].Enable()
		olds[i].Disable()
		i += 1
	endwhile
	if made > 0
		PlayAt(SigfBelieveIt, news[0])
	endif
	SigfLib.Say("Believe it! Everyone in Skyrim is Naruto now!")
	return made
EndFunction

; Extra Narutos poof in ahead of the player (the edge of town is empty), all at once.
Function Crowd(int count)
	Actor[] news = new Actor[24]
	int i = 0
	while i < count && i < 24
		ObjectReference m = SigfLib.Front(260.0 + Utility.RandomFloat(0.0, 450.0), Utility.RandomFloat(-330.0, 330.0))
		Poof(m)
		news[i] = MakeNaruto(m, 1.0, true)
		m.Delete()
		i += 1
	endwhile
	Utility.Wait(0.45)
	i = 0
	while i < count && i < 24
		news[i].Enable()
		i += 1
	endwhile
EndFunction

; Walks the player into the middle of the village: next to the farthest villager found nearby.
Function GoToVillage()
	Actor p = Game.GetPlayer()
	Actor best = None
	float bd = 0.0
	int i = 0
	while i < 14
		Actor a = Game.FindRandomActor(p.GetPositionX(), p.GetPositionY(), p.GetPositionZ(), 6000.0)
		if a && a != p && !a.IsDead() && a.GetActorBase() != SigfNaruto
			float d = p.GetDistance(a)
			if d > bd && d < 5000.0
				bd = d
				best = a
			endif
		endif
		i += 1
	endwhile
	if best
		SigfLib.Log("moving to the village, " + bd + " units away")
		p.MoveTo(best, -140.0, -140.0, 10.0)
		SigfLib.Look(best)
		Utility.Wait(1.5)
	endif
EndFunction

Function MakePlayerNaruto()
	Actor p = Game.GetPlayer()
	p.UnequipAll()
	p.AddItem(SigfOrangeSuit, 1, true)
	p.AddItem(SigfNinjaSandals, 1, true)
	p.AddItem(SigfLeafHeadband, 1, true)
	p.AddItem(SigfKunai, 1, true)
	p.EquipItem(SigfOrangeSuit, false, true)
	p.EquipItem(SigfNinjaSandals, false, true)
	p.EquipItem(SigfLeafHeadband, false, true)
	p.EquipItem(SigfKunai, false, true)
EndFunction

; A crowd of shadow clones poofs in around the player, all at once (the view ahead and behind stays clear).
Function ShadowClones(int count, float radius = 300.0)
	Actor p = Game.GetPlayer()
	Actor[] news = new Actor[8]
	float[] offs = new float[8]
	offs[0] = -38.0
	offs[1] = 38.0
	offs[2] = -18.0
	offs[3] = 18.0
	offs[4] = -58.0
	offs[5] = 58.0
	offs[6] = 0.0
	offs[7] = 8.0
	PlayAt(SigfCloneJutsu, p)
	SigfLib.Say("Shadow Clone Jutsu!  Dattebayo!")
	int i = 0
	while i < count && i < 8
		float a = p.GetAngleZ() + offs[i]
		Actor n = MakeNaruto(p, 1.0, true)
		float rr = radius + 90.0 * (i % 3)
		n.MoveTo(p, rr * Math.Sin(a), rr * Math.Cos(a), 0.0)
		Poof(n)
		news[i] = n
		i += 1
	endwhile
	Utility.Wait(0.45)
	i = 0
	while i < count && i < 8
		news[i].Enable()
		i += 1
	endwhile
EndFunction

; The Naruto closest to a target (None when there is none).
Actor Function NearestNaruto(ObjectReference to)
	Actor best = None
	float bd = 999999.0
	int i = 0
	while i < cloneCount
		Actor c = clones[i]
		if c && !c.IsDead() && !c.IsDisabled()
			float d = c.GetDistance(to)
			if d < bd
				bd = d
				best = c
			endif
		endif
		i += 1
	endwhile
	return best
EndFunction

; Every Naruto goes for the foe, the foe goes for the nearest Naruto.
Function Engage(Actor foe)
	int i = 0
	while i < cloneCount
		Actor c = clones[i]
		if c && !c.IsDead() && !c.IsDisabled()
			c.StartCombat(foe)
		endif
		i += 1
	endwhile
	Actor near = NearestNaruto(foe)
	if near
		foe.StartCombat(near)
	endif
EndFunction

; ---------- Rasengan ----------

Function Rasengan(Actor caster, Actor target)
	if !caster || !target || target.IsDead()
		return
	endif
	SigfLib.Say("Rasengan!")
	SigfLib.Log("rasengan start")
	SigfLib.FaceTo(caster, target)
	Utility.Wait(0.3)
	PlayAt(SigfRasenganShout, caster)
	float a = caster.GetAngleZ()
	ObjectReference orb = caster.PlaceAtMe(SigfRasenganOrb)
	orb.MoveTo(caster, 70.0 * Math.Sin(a) + 55.0 * Math.Cos(a), 70.0 * Math.Cos(a) - 55.0 * Math.Sin(a), 105.0)
	SigfLib.Log("orb at " + orb.GetPositionX() + "," + orb.GetPositionY() + "," + orb.GetPositionZ() + " caster " + caster.GetPositionX() + "," + caster.GetPositionY() + " angle " + a)
	PlayAt(SigfRasenganCharge, orb)
	orb.TranslateTo(orb.GetPositionX(), orb.GetPositionY(), orb.GetPositionZ(), 0.0, 0.0, 900.0, 1.0, 450.0)
	Utility.Wait(1.2)
	float t = 0.0
	while orb.GetDistance(target) > 130.0 && t < 5.0
		orb.TranslateToRef(target, 900.0, 0.0)
		Utility.Wait(0.2)
		t += 0.2
	endwhile
	SigfLib.Log("rasengan arrived after " + t + " s, distance " + orb.GetDistance(target))
	orb.StopTranslation()
	orb.PlaceAtMe(ExplosionShockMass01)
	orb.PlaceAtMe(fakeForceBall1024ByFormula)
	PlayAt(SigfRasenganHit, orb)
	SigfLib.Shake(0.5, 0.8)
	target.DamageActorValue("Health", 120.0)
	caster.PushActorAway(target, 14.0)
	; the orb bursts into a swelling blue shockwave
	float k = 1.0
	while k <= 6.0
		orb.SetScale(1.0 + 0.8 * k)
		Utility.Wait(0.05)
		k += 1.0
	endwhile
	orb.Disable()
	orb.Delete()
EndFunction

; ---------- enemies ----------

; A gang of bandits appears in an arc ahead and charges the Narutos. Returns the one in the middle.
Actor Function Wave(int count)
	Actor lead = None
	int i = 0
	while i < count
		Actor f = SigfLib.Spawn(EncBandit04Melee1HNordM, "bandit", 750.0, -300.0 + 150.0 * i)
		if f
			Engage(f)
			if i == count / 2
				lead = f
			endif
		endif
		i += 1
	endwhile
	return lead
EndFunction

ActorBase Function GetBandit()
	return EncBandit04Melee1HNordM
EndFunction

Actor Function GetKurama()
	return kurama
EndFunction

Actor Function SummonKurama(float dist = 1500.0, float side = 0.0)
	Actor k = SigfLib.Spawn(SigfKurama, "kurama", dist, side)
	if !k
		return None
	endif
	Engage(k)
	SigfLib.Look(k)
	kurama = k
	k.SetScale(6.0)
	k.SetActorValue("Aggression", 2)
	k.SetActorValue("Confidence", 4)
	SigfKuramaFlame.Play(k, -1.0)
	SigfLib.Say("Kurama, the Nine-Tailed Fox, awakens! Naruto: Not the ramen shop!")
	SigfLib.Shake(0.8, 2.0)
	return k
EndFunction
