extends BaseSignalBus

""" ==== Health Component Signals ==== """
## To be called by an entity when its health component's health value is changed
signal health_component_value_changed(p_reporting_entity, p_health_component: HealthComponent, p_old_health: float, p_new_health: float)
## To be called by an Entity when its health component's health reaches 0
signal health_component_died(p_reporting_entity, p_health_component: HealthComponent)

""" ==== Misc. Signals ===="""

signal sandbox_generate_new_random_nav_pos()

signal world_state_updated(p_world_state: Dictionary)
