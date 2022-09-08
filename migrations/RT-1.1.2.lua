for each, terminalStuff in pairs(global.ZiplineTerminals) do
	if (terminalStuff.entity.valid) then
		terminalStuff.tag = terminalStuff.entity.force.add_chart_tag(terminalStuff.entity.surface, {position=terminalStuff.entity.position, text=terminalStuff.name, icon={type="item", name="RTZiplineTerminalItem"}})
	else
		global.ZiplineTerminals[each] = nil
	end
end
