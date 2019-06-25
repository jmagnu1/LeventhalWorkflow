function archiveVideos = archiveVideo(d)
% d = dir2(videosPath,'-r','*.avi');
% check if archive already exists
archiveVideos = {};
for iFile = 1:numel(d)
    tic;
    reader = VideoReader(fullfile(d(iFile).folder,d(iFile).name));
    archivePath = fullfile(fullfile(d(iFile).folder,['archive_',d(iFile).name]));
    disp(['Archiving: ',archivePath]);
    writer = VideoWriter(archivePath,'Archival');
    open(writer);
    while hasFrame(reader)
        img = readFrame(reader);
        writeVideo(writer,img);
    end
    
    close(writer);
    archiveVideos{iFile} = archivePath;
    toc;
end