
# PlanAhead Launch Script for Post-Synthesis pin planning, created by Project Navigator

create_project -name fpgamiddlewareproject -dir "/home/alwynster/git/fpgamiddlewareproject/planAhead_run_4" -part xc6slx9tqg144-2
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/alwynster/git/fpgamiddlewareproject/genericProject.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/alwynster/git/fpgamiddlewareproject} }
set_param project.pinAheadLayout  yes
set_property target_constrs_file "/home/alwynster/git/fpgamiddlewareproject/src/mapping_fix.ucf" [current_fileset -constrset]
add_files [list {/home/alwynster/git/fpgamiddlewareproject/src/mapping_fix.ucf}] -fileset [get_property constrset [current_run]]
add_files [list {elasticNode.ucf}] -fileset [get_property constrset [current_run]]
link_design
