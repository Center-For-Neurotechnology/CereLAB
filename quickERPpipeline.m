%% Needs to be Manually Edited Every Time!

pID = 'MG110';
data_dir = ['C:\Britni\Data\' pID];
cd(data_dir)

filename = 'network_raw';
subj_dir = [data_dir '\' filename];

%% Initialization and Data Porting (BCD)
% If something goes wrong, you're probably in the wrong folder

mkdir(subj_dir)

files = {'20170410-090845-001'};

k = 0;

for s = 1:length(files)
  
    onechan = openNSx([data_dir '\' files{s} '.ns3'],'report','c:1');
    datalength = onechan.MetaTags.DataPoints;
    clear onechan
    
    for i = 0:floor(datalength/5000000)
        partialdata = openNSx([data_dir '\' files{s} '.ns3'],['t:' num2str(i*5000000) ':' num2str((i+1)*5000000)]);
        save([subj_dir '\' filename '_' num2str(k+1) '.mat'], 'partialdata', '-v7.3')
        clear partialdata
        k = k+1;
    end
    
end

for i = 1:k
    load([subj_dir '\' filename '_' num2str(i) '.mat'])
    figure
    plot(partialdata.Data(15,:),'b')
    hold on
    plot(partialdata.Data(min(size(partialdata.Data,1),129),:),'k')
%     plot(partialdata.Data(end-1,:),'k')
    plot(diff(mean(partialdata.Data,1)),'r')
    %title([files{i} ', total channels: ' num2str(size(partialdata.Data,1))])
    title([num2str(i) ', total channels: ' num2str(size(partialdata.Data,1))])
    clear partialdata
end

data = [];
for i = [1:3 5:7]
    load([subj_dir '\' filename '_' num2str(i) '.mat'])
    if isempty(data)
        data = partialdata;
        data.MetaTags.DataPoints = length(data.Data);
        data.MetaTags.DataDurationSec = length(data.Data)/data.MetaTags.SamplingFreq;
    else
        data.Data = [data.Data partialdata.Data];
        data.MetaTags.DataPoints = length(data.Data);
        data.MetaTags.DataDurationSec = length(data.Data)/data.MetaTags.SamplingFreq;
    end
    clear partialdata
end
save([subj_dir '\' filename '.mat'], 'data', '-v7.3')

stimbystim{1}.data = data.Data;
save([subj_dir '\' filename '_stimbystim.mat'], 'stimbystimdata', '-v7.3')

%% Find the stimulation artifacts using triggers and reorganize the data accordingly

databystim = analogartifactdetection(stimbystim, 129,2000);
databystim{1}.stimchans = stimchans;
save([subj_dir '\' filename '_databystim.mat'], 'databystim','-v7.3')
%% Useful time-domain plots

load([subj_dir '\' filename '_databystim.mat'])

chans = unique(databystim{1}.stimchans(:,1));
dat = databystim;

for s = 1:length(chans)
    idx = find(dat{1}.stimchans(:,1) == chans(s));
    databystim{s}.data = dat{1}.data(idx,:,:);
end

save([subj_dir '\' filename '_databystim_reorg.mat'], 'databystim','-v7.3')

Fs = (length(databystim{1}.data)-1)/2;
for s = 1:length(databystim)
    figure()
    for ch = 1:64
        subplot(8,8,ch)
        plot(squeeze(databystim{s}.data(:,ch,:))','Color',[0.5 0.5 0.5])
        hold on
        plot(squeeze(mean(databystim{s}.data(:,ch,:),1)),'LineWidth',2)
    end
    title([num2str(s) ': ' num2str(databystim{1}.stimchans(s,1)) '-' num2str(databystim{1}.stimchans(s,2))])
end

%% Find CCEPs
load([subj_dir '\' filename '_databystim_reorg.mat'])

Fs = (length(databystim{1}.data)-1)/2;
[CCEP CCav] = calcMEP(databystim,ceil(Fs+(25*Fs/1000)):Fs+(100*Fs/1000));
[bCCEP bCCav] = calcMEP(databystim,Fs-(100*Fs/1000):floor(Fs-(25*Fs/1000)));
for i = 1:size(databystim,1)
    for j = 1:size(databystim,2)
        stdCCEP{i,j} = std(databystim{i,j}.data(:,:,Fs-(100*Fs/1000):floor(Fs-(25*Fs/1000))),[],3);
        %stdCCav(i,j,:) = reshape(mean(stdCCEP{i,j},1),[1,1,size(stdCCEP{i,j},2)]);
        stdCCav(i,j,:) = mean(stdCCEP{i,j},1);
    end
end

save([subj_dir '\' filename '_CCEPAmplitude.mat'],'CCEP','CCav','bCCEP','bCCav','stdCCEP','stdCCav')

%% Need to include HIST PLOTS here
load([subj_dir '\' filename '_databystim_reorg.mat'])
load([subj_dir '\' filename '_CCEPAmplitude.mat'])

CCav = squeeze(CCav);
stdCCav = squeeze(stdCCav);

for s = 1:length(databystim)
    figure()
    hist(squeeze(CCav(s,:)./stdCCav(s,:)),20);
    title([num2str(s) ': ' num2str(databystim{1}.stimchans(s,1)) '-' num2str(databystim{1}.stimchans(s,2))])    
end
