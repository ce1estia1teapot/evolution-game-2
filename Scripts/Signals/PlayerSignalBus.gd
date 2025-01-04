extends BaseSignalBus

""" ==== STATE CHANGE SIGNALS ==== """
signal player_state_transitioned(initial_state: BaseState, end_state: BaseState)

""" === Combat Signals === """
signal player_attack_initiated(target_hitbox: HitboxComponent, attack: Attack)

""" ==== MISC. SIGNALS ==== """
signal inventory_interacted(p_target_body: CollisionObject3D, p_inventory: InventoryComponent)
