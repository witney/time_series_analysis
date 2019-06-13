% plots 3D MRI recon with merged CT for ecog channels
% adjusts colors of ecog to make heatmap
% INPUTS:
% s = freesurfer mesh
% ecog = matrix with ecog locations
% norm = matrix with scaling factors for ecog colors


function []=plot_3D_brain_with_ecog_heatmap(s,ecog,norm)

figure; hold on

% plot 3D MR recon
ax1 = axes;
axis equal;
% axes('buttondownfcn', @buttondownfcn);  % assign callback
set(gca,'NextPlot','add');                % add next plot to current axis

trisurf(s.cortexR.tri, s.cortexR.vert(:, 1), s.cortexR.vert(:, 2), s.cortexR.vert(:, 3), 'FaceVertexCData', 1, 'CDataMapping', 'direct', 'linestyle', 'none', 'FaceAlpha', 0.6,'hittest','off');
trisurf(s.cortexL.tri, s.cortexL.vert(:, 1), s.cortexL.vert(:, 2), s.cortexL.vert(:, 3), 'FaceVertexCData', 1, 'CDataMapping', 'direct', 'linestyle', 'none', 'FaceAlpha', 0.6,'hittest','off');

colormap(ax1,[.7 .7 .7]);
view(90,0);                             % view to start from
c = camlight('headlight');              % add light
set(c,'style','infinite');              % set style of light
material('dull');
lighting('phong');

% ecog with heatmap coloring
ax2 = axes;
set(gca,'Color','None');
axis equal;
set(gca,'NextPlot','add');              % add next plot to current axis

for i=1:size(norm)
    scatter3(squeeze(ecog(i,:,1)),squeeze(ecog(i,:,2)),squeeze(ecog(i,:,3)),120,norm(i,:),'filled','MarkerEdgeColor','w') 
end

colormap(ax2,parula);

Link = linkprop([ax1, ax2],{'CameraUpVector', 'CameraPosition', 'CameraTarget', 'XLim', 'YLim', 'ZLim'});
% setappdata(gcf, 'StoreTheLink', Link);

colorbar;


end
