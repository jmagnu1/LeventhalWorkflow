function archiveVideos = archiveVideo(d)
% d = dir2(videosPath,'-r','*.avi');
% check if archive already exists
archiveVideos = {};
for iFile = 1:numel(d)
    tic;
    [~,name,ext] = fileparts(d(iFile).name);
    filename = [name,ext];
    reader = VideoReader(fullfile(d(iFile).folder,filename));
    archivePath = fullfile(fullfile(d(iFile).folder,['archive_',filename]));
    disp(['Archiving #',num2str(iFile),': ',filename]);
    writer = VideoWriter(archivePath,'Archival');
    open(writer);
    iFrame = 0;
    frameLimit = Inf; % for testing
    while hasFrame(reader)
        iFrame = iFrame + 1;
        img = readFrame(reader);
        writeVideo(writer,img);
            break;
        end
    end
    
    close(writer);
    archiveVideos{iFile} = [archivePath,'.mj2'];
    toc;
end