%% 根据rfcapture论文的硬算公式计算指定坐标上的功率大小
% fTsrampRTZ: 硬算公式的中间值f(n,m,zs,ts,tsRamp)，（ts为长时间,tsRamp为短时间）
% pointCoor: 指定坐标，n行3列
% antCoor: 天线坐标
% nRx: 接收天线数量
% nTx: 发射天线数量
% dCa: 应减去的多余天线线缆距离
% tsRamp: 一个斜坡内的时间坐标
% fBw: 扫频带宽
% fTr: 扫频频率
% dLambda: 波长
function fTsrampRTZ=rfcaptureCo2F(pointCoor,antCoor,nRx,nTx,dCa,tsRamp,fBw,fTr,dLambda,useGPU)
%% 计算r(n,m)(X(ts),Y(ts),z)，（ts为长时间）
rsCoRT=zeros(size(pointCoor,1),nRx,nTx,'single');%r(n,m)(X(ts),Y(ts),z)，（ts为长时间）
for iRx=1:nRx
    for iTx=1:nTx
        rsCoRT(:,iRx,iTx)=sqrt( ...
            (pointCoor(:,1)-repmat(single(antCoor(iRx,1)),size(pointCoor,1),1)).^2 ...
            + (pointCoor(:,2)-repmat(single(antCoor(iRx,2)),size(pointCoor,1),1)).^2 ...
            + (pointCoor(:,3)-repmat(single(antCoor(iRx,3)),size(pointCoor,1),1)).^2 ...
            ) ...
            + sqrt( ...
            (pointCoor(:,1)-repmat(single(antCoor(iTx+nRx,1)),size(pointCoor,1),1)).^2 ...
            + (pointCoor(:,2)-repmat(single(antCoor(iTx+nRx,2)),size(pointCoor,1),1)).^2 ...
            + (pointCoor(:,3)-repmat(single(antCoor(iTx+nRx,3)),size(pointCoor,1),1)).^2 ...
            ) ...
            + dCa;
    end
end
%% 计算f(n,m,zs,ts,tsRamp)，（ts为长时间,tsRamp为短时间）
if useGPU
    rsCoRT=gpuArray(rsCoRT);
    tsRamp=gpuArray(tsRamp);
end
rsCoRTTsramp=permute(repmat(rsCoRT,1,1,1,length(tsRamp)),[4,2,3,1]);
tsCoRTTsramp=repmat(tsRamp',1,size(rsCoRTTsramp,2),size(rsCoRTTsramp,3),size(rsCoRTTsramp,4));
fTsrampRTZ=exp( ...
    1i*2*pi*fBw*fTr.*rsCoRTTsramp/3e8 ...
    .*tsCoRTTsramp ...
    ) ...
    .*exp( ...
    1i*2*pi*rsCoRTTsramp/dLambda ...
    );
    
end