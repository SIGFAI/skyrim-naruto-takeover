Scriptname SigfPuff extends ObjectReference
{A cartoon smoke cloud that swells and disappears: the Naruto "poof". Re-setting the scale each step also keeps it fully opaque (a newly loaded object otherwise fades in slowly).}

int step = 0

Event OnLoad()
	SetScale(0.6)
	RegisterForSingleUpdate(0.03)
EndEvent

Event OnUpdate()
	step += 1
	if step <= 8
		SetScale(0.6 + 0.1 * step)
	elseif step >= 12
		Disable()
		Delete()
		return
	endif
	RegisterForSingleUpdate(0.07)
EndEvent
