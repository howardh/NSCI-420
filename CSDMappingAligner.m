%Computes the alignment with the highest average zero-lag correlation
function ret=CSDMappingAligner(csd1, csd2)
    %Initialize variables
    temp1=size(csd1);
    temp2=size(csd2);
    times=min(length(csd1),length(csd2));
    trials=min(temp1(3),temp2(3));
    ret=zeros(32,32,100,floor(times/50));

    %Make some pretties
    %plotCorrelation(csd1,csd2,4,[1000:1100]);

    %Compute correlations
    %csd1=squeeze(mean(csd1,3));
    %csd2=squeeze(mean(csd2,3));
    %time=[1:50];
    %while (time(50) < min(length(csd1),length(csd2)))
    %    for chX=1:32
    %        for chY=1:32
    %            x=squeeze(csd1(chX,time));
    %            y=squeeze(csd2(chY,time));
    %            ret(chX,chY,time(50)/50)=computeCorrelation(x,y);
    %        end
    %    end
    %    time=time+50;
    %    disp(time(50));
    %end
    time=[1:50];
    while (time(50) < times)
        for trial=1:trials
            for chX=1:32
                for chY=1:32
                    x=squeeze(csd1(chX,time,trial));
                    y=squeeze(csd2(chY,time,trial));
                    ret(chX,chY,time(50)/50)=computeCorrelation(x,y);
                end
            end
        end
        time=time+50;
        disp(time(50));
    end

    %Formatting for displaying, and display
    ret=mean(ret,3);
    ret=mean(ret,4);
    ret=squeeze(ret)
    imagesc(ret);
    colorbar;

    %Compute alignment
    corrMean=zeros(1,21);
    for k=-10:10
        v=diag(ret,k);
        corrMean(11+k)=mean(v);
        disp([num2str(k) ' ' num2str(corrMean(k+11))]);
    end
    ret=argmax(corrMean)-11;
    disp(['Max correlation: ' num2str(ret)]);
end

function ret=calculateScore(dt,dc,csd1,csd2)
    ret=0;
end

function ret=plotCorrelation(csd1,csd2,channel,time)
    x=squeeze(csd1(channel,time,1));
    y=squeeze(csd2(channel-1,time,1));
    scatter(x,y);
    disp(computeCorrelation(x,y));
end

function ret=computeCorrelation(x,y)
    ret=mean((x-mean(x)).*(y-mean(y)))/(std(x)*std(y));
end

function ret=argmax(v)
    x=size(v)
    ret=1;
    for i=2:x(2)
        if (v(ret) < v(i))
            ret=i;
        end
    end
end
