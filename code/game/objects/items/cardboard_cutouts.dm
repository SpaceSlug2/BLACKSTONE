//Cardboard cutouts! They're man-shaped and can be colored with a crayon to look like a human in a certain outfit, although it's limited, discolored, and obvious to more than a cursory glance.
/obj/item/cardboard_cutout
	name = "cardboard cutout"
	desc = ""
	icon = 'icons/obj/cardboard_cutout.dmi'
	icon_state = "cutout_basic"
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = FLAMMABLE
	// Possible restyles for the cutout;
	// add an entry in change_appearance() if you add to here
	var/list/possible_appearances = list("Assistant", "Clown", "Mime",
		"Traitor", "Nuke Op", "Cultist", "Clockwork Cultist",
		"Revolutionary", "Wizard", "Shadowling", "Xenomorph", "Xenomorph Maid", "Swarmer",
		"Ash Walker", "Deathsquad Officer", "Ian", "Slaughter Demon",
		"Laughter Demon", "Private Security Officer")
	var/pushed_over = FALSE //If the cutout is pushed over and has to be righted
	var/deceptive = FALSE //If the cutout actually appears as what it portray and not a discolored version

	var/lastattacker = null

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/cardboard_cutout/attack_hand(mob/living/user)
	if(user.used_intent.type == INTENT_HELP || pushed_over)
		return ..()
	user.visible_message(span_warning("[user] pushes over [src]!"), span_danger("I push over [src]!"))
	playsound(src, 'sound/blank.ogg', 50, TRUE)
	push_over()

/obj/item/cardboard_cutout/proc/push_over()
	name = initial(name)
	desc = ""
	icon = initial(icon)
	icon_state = "cutout_pushed_over"
	remove_atom_colour(FIXED_COLOUR_PRIORITY)
	alpha = initial(alpha)
	pushed_over = TRUE

/obj/item/cardboard_cutout/attack_self(mob/living/user)
	if(!pushed_over)
		return
	to_chat(user, span_notice("I right [src]."))
	desc = initial(desc)
	icon = initial(icon)
	icon_state = initial(icon_state) //This resets a cutout to its blank state - this is intentional to allow for resetting
	pushed_over = FALSE

/obj/item/cardboard_cutout/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/toy/crayon))
		change_appearance(I, user)
		return
	// Why yes, this does closely resemble mob and object attack code.
	if(I.item_flags & NOBLUDGEON)
		return
	if(!I.force)
		playsound(loc, 'sound/blank.ogg', get_clamped_volume(), TRUE, -1)
	else if(I.hitsound)
		playsound(loc, pick(I.hitsound), get_clamped_volume(), TRUE, -1)

	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)

	if(I.force)
		user.visible_message(span_danger("[user] hits [src] with [I]!"), \
			span_danger("I hit [src] with [I]!"))
		if(prob(I.force))
			push_over()

/obj/item/cardboard_cutout/bullet_act(obj/projectile/P)
	if(istype(P, /obj/projectile/bullet/reusable))
		P.on_hit(src, 0)
	visible_message(span_danger("[src] is hit by [P]!"))
	playsound(src, 'sound/blank.ogg', 50, TRUE)
	if(prob(P.damage))
		push_over()
	return BULLET_ACT_HIT

/obj/item/cardboard_cutout/proc/change_appearance(obj/item/toy/crayon/crayon, mob/living/user)
	if(!crayon || !user)
		return
	if(pushed_over)
		to_chat(user, span_warning("Right [src] first!"))
		return
	if(crayon.check_empty(user))
		return
	if(crayon.is_capped)
		to_chat(user, span_warning("Take the cap off first!"))
		return
	var/new_appearance = input(user, "Choose a new appearance for [src].", "26th Century Deception") as null|anything in sortList(possible_appearances)
	if(!new_appearance || !crayon || !user.canUseTopic(src, BE_CLOSE))
		return
	if(!do_after(user, 10, FALSE, src, TRUE))
		return
	user.visible_message(span_notice("[user] gives [src] a new look."), span_notice("Voila! You give [src] a new look."))
	crayon.use_charges(1)
	crayon.check_empty(user)
	alpha = 255
	icon = initial(icon)
	if(!deceptive)
		add_atom_colour("#FFD7A7", FIXED_COLOUR_PRIORITY)
	switch(new_appearance)
		if("Assistant")
			name = "[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"
			desc = ""
			icon_state = "cutout_greytide"
		if("Clown")
			name = pick(GLOB.clown_names)
			desc = ""
			icon_state = "cutout_clown"
		if("Mime")
			name = pick(GLOB.mime_names)
			desc = ""
			icon_state = "cutout_mime"
		if("Traitor")
			name = "[pick("Unknown", "Captain")]"
			desc = ""
			icon_state = "cutout_traitor"
		if("Nuke Op")
			name = "[pick("Unknown", "COMMS", "Telecomms", "AI", "stealthy op", "STEALTH", "sneakybeaky", "MEDIC", "Medic")]"
			desc = ""
			icon_state = "cutout_fluke"
		if("Cultist")
			name = "Unknown"
			desc = ""
			icon_state = "cutout_cultist"
		if("Clockwork Cultist")
			name = "[pick(GLOB.first_names_male)] [pick(GLOB.last_names)]"
			desc = ""
			icon_state = "cutout_servant"
		if("Revolutionary")
			name = "Unknown"
			desc = ""
			icon_state = "cutout_viva"
		if("Wizard")
			name = "[pick(GLOB.wizard_first)], [pick(GLOB.wizard_second)]"
			desc = ""
			icon_state = "cutout_wizard"
		if("Shadowling")
			name = "Unknown"
			desc = ""
			icon_state = "cutout_shadowling"
		if("Xenomorph")
			name = "alien hunter ([rand(1, 999)])"
			desc = ""
			icon_state = "cutout_fukken_xeno"
			if(prob(25))
				alpha = 75 //Spooky sneaking!
		if("Xenomorph Maid")
			name = "lusty xenomorph maid ([rand(1, 999)])"
			desc = ""
			icon_state = "cutout_lusty"
		if("Swarmer")
			name = "Swarmer ([rand(1, 999)])"
			desc = ""
			icon_state = "cutout_swarmer"
		if("Ash Walker")
			name = lizard_name(pick(MALE, FEMALE))
			desc = ""
			icon_state = "cutout_free_antag"
		if("Deathsquad Officer")
			name = pick(GLOB.commando_names)
			desc = ""
			icon_state = "cutout_deathsquad"
		if("Ian")
			name = "Ian"
			desc = ""
			icon_state = "cutout_ian"
		if("Slaughter Demon")
			name = "slaughter demon"
			desc = ""
			icon = 'icons/mob/mob.dmi'
			icon_state = "daemon"
		if("Laughter Demon")
			name = "laughter demon"
			desc = ""
			icon = 'icons/mob/mob.dmi'
			icon_state = "bowmon"
		if("Private Security Officer")
			name = "Private Security Officer"
			desc = ""
			icon_state = "cutout_ntsec"
	return 1

/obj/item/cardboard_cutout/setDir(newdir)
	dir = SOUTH

/obj/item/cardboard_cutout/adaptive //Purchased by Syndicate agents, these cutouts are indistinguishable from normal cutouts but aren't discolored when their appearance is changed
	deceptive = TRUE
