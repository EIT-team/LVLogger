function [ v ] = LVimport( varargin )
%LVIMPORT Imports data saved in ASCII format exported from labview
%   fname= ASCII file with data
%   data is stored in structure v in following format
%     v.description as string
%     v.date    \    Date and time stamps
%     v.timestr /    as string
%     v.fs dbl equal to fs
%     v.datalabels cell of column headings
%     v.data matrix of voltages
%     v.t is time vector calculated from (0:1:length(v.data)-1)/v.fs - NOW
%     REMOVED
%
% function assumes the format set in write file with headers.vi :
%
%   Description
%   ####
%   fs
%   ####
%   date
%   ####
%   time
%   #####
%   col1 col2 col3 etc.
%   ### ###  ###
% which is comma delimited and with 9 header rows
%
if isempty(varargin)
    %get files from user
    [filename, pathname] = uigetfile('*', 'Choose LabView a file you mug!!!', ...
        'MultiSelect','off');
    %error if none selected
    if isequal(filename,0)||isequal(pathname,0)
        error('No file chosen. Choose a file you mug, stop wasting my time!')
    end
    fullfile=[pathname filename];
else
    fullfile=varargin{1};
end

P=importdata(fullfile,',',9); %load data with , delimiter and 9 header rows

v.description=P.textdata{2,1};
v.date=P.textdata{6,1};
v.timestr=P.textdata{8,1};

% v.fs=str2double(P.textdata(4,:)); %convert from str to num
temp_fs=cell2mat(P.textdata(4,1));
markers=strfind(temp_fs,',');
if isempty(markers)
    v.fs=str2double(temp_fs);
else
    v.fs=zeros(length(markers)+1,1);
    for fs_gen_loop=1:length(markers)+1
        if fs_gen_loop==1
            string_lims=1:markers(fs_gen_loop)-1;
        elseif fs_gen_loop==length(markers)+1
            string_lims=markers(fs_gen_loop-1)+1:length(temp_fs);
        else
            string_lims=markers(fs_gen_loop-1)+1:markers(fs_gen_loop)-1;
        end
        v.fs(fs_gen_loop)=str2double(temp_fs(string_lims));
    end
end

v.fs=v.fs(1,1); % KLUDGE
v.datalabels=P.colheaders;
v.data=P.data;
v.t=(0:1:length(v.data)-1)/v.fs; 
% data, now to be done in LV_load
end

