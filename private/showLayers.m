function showLayers(csd)
	x = repmat([-10 2010], 6, 1);
	csd.alignment
	y = [csd.alignment.layerI(1) csd.alignment.layerI(1); ...
	 	csd.alignment.layerII(1) csd.alignment.layerII(1); ...
		csd.alignment.layerIV(1) csd.alignment.layerIV(1); ...
		csd.alignment.layerV(1) csd.alignment.layerV(1); ...
		csd.alignment.layerVI(1) csd.alignment.layerVI(1); ...
		csd.alignment.layerVI(end)+1 csd.alignment.layerVI(end)+1]-0.5;
	for i=1:6
		line(x(i,:), y(i,:), ...
					'LineStyle', '--', ...
					'LineWidth', 2, ...
					'Color', [0 0 0]);
	end
end