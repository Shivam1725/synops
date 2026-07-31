# Create the base floorplan and reserve room for macros/blockages.

banner "Create floorplan"
floorPlan -site $PLACE_SITE -r $CORE_ASPECT_RATIO $CORE_UTILIZATION $CORE_MARGIN_LEFT $CORE_MARGIN_BOTTOM $CORE_MARGIN_RIGHT $CORE_MARGIN_TOP

# Add project-specific macro placement and blockages here using placeholders.
puts "INFO: Add macro placement, halos, and placement/routing blockages for your design-specific blocks."
