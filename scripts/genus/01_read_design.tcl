# Configure Genus search paths and read the RTL.

banner "Configure Genus input databases"
set_db init_lib_search_path $INIT_LIB_SEARCH_PATHS
set_db library [list $LIB_SLOW $LIB_FAST]
set_db lef_library $LEF_FILES
set_db qrc_tech_file $QRC_TECH_FILE
set_db hdl_search_path $HDL_SEARCH_PATHS

# Read and elaborate the design top.
read_hdl $RTL_FILES
elaborate $TOP_MODULE
