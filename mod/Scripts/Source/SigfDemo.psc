Scriptname SigfDemo extends Quest
{Demo: plays the clip.txt moments in order.}

Quest Property ModQuest Auto

Event OnInit()
	if IsRunning()
		RegisterForSingleUpdate(0.5)
	endif
EndEvent

Event OnUpdate()
	Debug.Trace("SIGF_DEMO start")
	SigfMod m = ModQuest as SigfMod
	m.DemoMode = True
	Actor p = Game.GetPlayer()
	; 1. the takeover: the player and the crowd become Naruto
	SigfLib.Say("Naruto Takeover!")
	m.MakePlayerNaruto()
	m.Crowd(6)
	m.Takeover(3500.0, 6, True)
	; 2. shadow clones around the player
	m.ShadowClones(8)
	Utility.Wait(1.0)
	; 3. a bandit appears far ahead, the hero Rasengan blasts it
	Actor foe = SigfLib.Spawn(m.GetBandit(), "bandit", 650.0, 0.0)
	SigfLib.Look(foe)
	m.Rasengan(p, foe)
	Utility.Wait(2.0)
	; the rest of the gang charges the clone army
	m.Wave(3)
	Utility.Wait(3.0)
	; 4. Kurama
	m.SummonKurama(950.0, 0.0)
	Utility.Wait(2.0)
	SigfLib.Say("I'm going to be Hokage! Dattebayo!")
	SigfLib.Look(m.GetKurama())
	m.Rasengan(p, m.GetKurama())
	Utility.Wait(8.0)
	Debug.Trace("SIGF_DEMO end")
EndEvent
