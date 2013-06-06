%Computes the alignment with the highest average zero-lag correlation
function ret=CSDMappingAligner2(csd1, csd2, name)
    %Initialize variables
    csd1.data=csd1.data([4:16],[1000:1200],:);
    size1=size(csd1.data);
    size2=size(csd2.data);
    times=size2(2)-size1(2);
    channels=size2(1)-size1(1);
    trials=min(size1(3),size2(3));
    csd1.data=csd1.data(:,:,[1:trials]);
    csd2.data=csd2.data(:,:,[1:trials]);
    tempCsd1=csd1.data(:);

    corrValues=zeros(channels,times);
    bestCh=1;
    bestT=1;
    for ch=1:channels
        disp(['Channel: ' num2str(ch)]);
        tic;
        for t=1:times
            channel=[4:16]-3+ch;
            time=[1000:1200]-999+t;
            tempCsd2=csd2.data(channel,time,:);
            tempCsd2=tempCsd2(:);
            corrValues(ch,t)=computeCorrelation(tempCsd1,tempCsd2);

            %Check if it's a better match
            if (mean(corrValues(ch,t)) > mean(corrValues(bestCh,bestT)))
                bestCh=ch;
                bestT=t;
            end
        end
        toc
    end

    %Make pretties and save it to a file
    fig=figure;
    imagesc(corrValues);
    colorbar;
    saveas(fig,name,'png');

    ret=[bestCh bestT];
end

function ret=plotCorrelation(csd1,csd2,channel,time)
    x=squeeze(csd1.data(channel,time,1));
    y=squeeze(csd2.data(channel-1,time,1));
    scatter(x,y);
    disp(computeCorrelation(x,y));
end

function ret=computeCorrelation(x,y)
    ret=mean((x-mean(x)).*(y-mean(y)))/(std(x)*std(y));
end

function ret=argmax(v)
    x=size(v);
    ret=1;
    for i=2:x(2)
        if (v(ret) < v(i))
            ret=i;
        end
    end
end
