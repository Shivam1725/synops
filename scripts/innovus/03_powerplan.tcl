# Connect power nets and build a starter power grid.

banner "Build power plan"
globalNetConnect $POWER_NET -type pgpin -pin $POWER_NET -inst * -override
globalNetConnect $GROUND_NET -type pgpin -pin $GROUND_NET -inst * -override
addRing -nets [list $POWER_NET $GROUND_NET] -width $RING_WIDTH -spacing $RING_SPACING
addStripe -nets [list $POWER_NET $GROUND_NET] -width $STRIPE_WIDTH -spacing $STRIPE_SPACING -set_to_set_distance $STRIPE_PITCH
sroute -connect {corePin padPin blockPin stripe ring}
