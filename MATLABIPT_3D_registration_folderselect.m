% MATLABでは4次元イメージを一気に読み込めないので、zスタックを1つずつ読み込む
% GPUを使用している
% 入力フォルダと出力フォルダを選択する
% フォルダを選択して、最初のファイルをターゲットとする

%% フォルダ選択
inputdir = uigetdir;
S = dir(inputdir);
outputdir = uigetdir;
output_path = [outputdir , '/'];
%% tifファイルの読み取り(targetのｚStack)
tic
path = [inputdir, '/', S(3).name];
file_info = imfinfo(path);
d1 = file_info(1).Height;
d2 = file_info(1).Width;
T = numel(file_info);
bit = file_info(1).BitDepth;
raw_IMG = zeros(d1,d2,T);
for t = 1:T
    raw_IMG(:,:,t) = imread(path, t);
end
disp('データ読み取り完了')
toc
Target = gpuArray(raw_IMG);

%% 1フレーム目書き込み
tic
IMG = cast(raw_IMG,['uint',num2str(bit)]);
imwrite(IMG(:,:,1),[output_path, '3Dreged_',  S(3).name,'.tif']);
for t = 2:T
    imwrite(IMG(:,:,t),[output_path, '3Dreged_', S(3).name,'.tif'],'WriteMode','append');
end
disp('書き込み完了')
toc
%% フォルダ内の全処理
for i = 4:size(S,1)
    %% tifファイルの読み取り(suorceのｚStack)
    tic
    path = [inputdir, '/', S(i).name];
    file_info = imfinfo(path);
    d1 = file_info(1).Height;
    d2 = file_info(1).Width;
    T = numel(file_info);
    bit = file_info(1).BitDepth;
    raw_IMG = zeros(d1,d2,T);
    for t = 1:T
        raw_IMG(:,:,t) = imread(path, t);
    end
    disp('データ読み取り完了')
    toc
    Source = gpuArray(raw_IMG);
    
    %% レジスト
    tic
    [D,moving_reg] = imregdemons(Source, Target);
    moving_reg = gather(moving_reg);
    disp('レジスト完了')
    toc

    %% 書き込み
    tic
    IMG = cast(moving_reg,['uint',num2str(bit)]);
    imwrite(IMG(:,:,1),[output_path, '3Dreged_',  S(i).name,'.tif']);
    for t = 2:T
        imwrite(IMG(:,:,t),[output_path, '3Dreged_', S(i).name,'.tif'],'WriteMode','append');
    end
    disp('書き込み完了')
    toc
    
end