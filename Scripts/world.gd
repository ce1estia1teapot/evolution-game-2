extends Node

## Dictionary in the form {author: last_report}
var WORLD_STATE: Dictionary = {}

""" ==== Built-in Functions ==== """
#region Build-in Functions
func _ready() -> void:
	MainSignalBus.report_for_world_state_update.connect(on_report_for_world_state_update)
#endregion

"""  ==== Signal Callbacks ===="""
func on_report_for_world_state_update(p_report: WorldStateReport) -> void:
	if not p_report.m_author:
		push_warning("Report contains no author: {var1}".format({"var1": p_report}))
		return
	if not p_report.report_type:
		push_warning("Report contains no type: {var1}".format({"var1": p_report}))
		return
	
	var author = p_report.m_author
	var report_type := p_report.report_type
	
	match report_type:
		Enums.WorldReportType.PUT:
			WORLD_STATE[author] = p_report
		Enums.WorldReportType.DELETE:
			WORLD_STATE.erase(author)
		_:
			push_warning("Report type not found in match: {var1}".format({"var1": p_report}))
