for _, force in pairs(game.forces) do
	local technologies = force.technologies
	local recipes = force.recipes
	if technologies["circuit-network"].researched then
		recipes["destruction-sensor"].enabled = true
	end
end
