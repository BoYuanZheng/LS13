/obj/item/weapon/paper_bin
	name = "paper bin"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper_bin1"
	item_state = "sheet-metal"
	throwforce = 0
	w_class = 3
	throw_speed = 3
	throw_range = 7
	pressure_resistance = 8
	burn_state = FLAMMABLE
	var/amount = 30					//How much paper is in the bin.
	var/list/papers = new/list()	//List of papers put in the bin for reference.

/obj/item/weapon/paper_bin/fire_act()
	if(!amount)
		return
	..()

/obj/item/weapon/paper_bin/burn()
	amount = 0
	extinguish()
	update_icon()
	return

/obj/item/weapon/paper_bin/MouseDrop(atom/over_object)
	var/mob/living/M = usr
	if(!istype(M) || M.incapacitated() || !Adjacent(M))
		return

	if(over_object == M)
		M.put_in_hands(src)

	else if(istype(over_object, /obj/screen/inventory/hand))
		var/obj/screen/inventory/hand/H = over_object
		if(!remove_item_from_storage(M))
			if(!M.unEquip(src))
				return
		switch(H.slot_id)
			if(slot_r_hand)
				M.put_in_r_hand(src)
			if(slot_l_hand)
				M.put_in_l_hand(src)

	add_fingerprint(M)


/obj/item/weapon/paper_bin/attack_paw(mob/user)
	return attack_hand(user)


/obj/item/weapon/paper_bin/attack_hand(mob/user)
	if(user.lying)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if(amount >= 1)
		amount--
		update_icon()

		var/obj/item/weapon/paper/P
		if(papers.len > 0)	//If there's any custom paper on the stack, use that instead of creating a new paper.
			P = papers[papers.len]
			papers.Remove(P)
		else
			P = new /obj/item/weapon/paper
			if(SSevent.holidays && SSevent.holidays[APRIL_FOOLS])
				if(prob(30))
					P.info = "<font face=\"[CRAYON_FONT]\" color=\"red\"><b>HONK HONK HONK HONK HONK HONK HONK<br>HOOOOOOOOOOOOOOOOOOOOOONK<br>APRIL FOOLS</b></font>"
					P.rigged = 1
					P.updateinfolinks()

		P.loc = user.loc
		user.put_in_hands(P)
		user.text2tab("<span class='notice'>You take [P] out of \the [src].</span>")
	else
		user.text2tab("<span class='warning'>[src] is empty!</span>")

	add_fingerprint(user)


/obj/item/weapon/paper_bin/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/paper))
		var/obj/item/weapon/paper/P = I
		if(!user.unEquip(P))
			return
		P.loc = src
		user.text2tab("<span class='notice'>You put [P] in [src].</span>")
		papers.Add(P)
		amount++
		update_icon()
	else
		return ..()

/obj/item/weapon/paper_bin/examine(mob/user)
	..()
	if(amount)
		user.text2tab("It contains " + (amount > 1 ? "[amount] papers" : " one paper")+".")
	else
		user.text2tab("It doesn't contain anything.")


/obj/item/weapon/paper_bin/update_icon()
	if(amount < 1)
		icon_state = "paper_bin0"
	else
		icon_state = "paper_bin1"
