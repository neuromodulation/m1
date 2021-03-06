function [p,s,v,F] = m1_plot_surface(filename,color,mni,method,dec)

if ~exist('method')
    method = 'linear'; % ,'nearest'
end

settings = m1_settings;
if ~exist('filename','var') 
    filename = settings.grid.ecog.surface;
end

if ~exist('color','var')
    color = [.7 .7 .7];
else 
    color = squeeze(color);
end



try
    try
        s=export(gifti(filename));
    catch
        [dir,fname,ext]=fileparts(filename);
        s=export(gifti(fullfile(dir,[fname '.surf.gii'])));
    end

catch
    try
    filename=m1_extract_surface(filename);
    s=export(gifti(filename));
    catch
        s=filename;
    end
end



if ~isfield(s,'vertices')
    try
        s=load(s);
    end
    
if isfield(s,'Vertices')
    s.vertices = s.Vertices;
    s.faces = s.Faces;  
end
end

if exist('dec','var') && ~isempty(dec) && dec
    s = reducepatch(s,length(s.faces)/dec);
end

if ischar(color)
    color =export(gifti(color));
    for a  =1:length(color.cdata)
        cc(a)=color.cdata(a);
    end
    color=cc';
end
   

if ~isnumeric(color) || numel(color)==3 && (~exist('mni','var') || isempty(mni))
    p=patch('vertices',s.vertices,'faces',s.faces,'Facecolor',color,'EdgeColor','none');
    v=[];
elseif (exist('mni','var') && length(mni) == length(color)) || length(color)==size(s.vertices,1)

    if length(color)~=length(s.vertices) && size(color,2)==1
     s.vertices=double(s.vertices)   ;
     F = scatteredInterpolant(mni(:,1),mni(:,2),mni(:,3),color,method);%,
     v=F(s.vertices(:,1),s.vertices(:,2),s.vertices(:,3));
   
     
     
    else
        v=color(:,1);
    end
     p=patch('vertices',s.vertices,'faces',s.faces,'CData',v,'FaceColor','interp','EdgeColor','none');
     set(p,'FaceVertexAlpha',abs(v));
%     set(p,'FaceAlpha','interp');

%     if ~isempty(pks) && length(pks<10)
% %         keyboard
%         [x,y,z] = sphere(50);
%         hold on
%     for a=1:length(pks)
%         surf(s.vertices(pks(a),1).*x,s.vertices(pks(a),2).*y,s.vertices(pks(a),3).*z,'EdgeColor','none','FaceColor','r');
%     end
%     end
     
else
    p=patch('vertices',s.vertices,'faces',s.faces,'FaceColor',[.5 .5 .5],'EdgeColor','none');
    v=[];
    warning('color not working')
end


axis equal
axis off
set(gcf,'color','k')
set(gca,'color','k');