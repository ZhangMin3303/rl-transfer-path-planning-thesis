function results = run_all_matlab_scripts(projectRoot)
%RUN_ALL_MATLAB_SCRIPTS Execute every MATLAB script in src and summarize status.
% Usage:
%   results = run_all_matlab_scripts(pwd)

if nargin < 1 || strlength(projectRoot) == 0
    projectRoot = fileparts(fileparts(mfilename("fullpath")));
end

projectRoot = char(projectRoot);
srcRoot = fullfile(projectRoot, "src");
files = dir(fullfile(srcRoot, "**", "*.m"));

set(0, "DefaultFigureVisible", "off");
fprintf("Running %d MATLAB scripts under %s\n", numel(files), srcRoot);

scriptName = strings(numel(files), 1);
relativePath = strings(numel(files), 1);
status = strings(numel(files), 1);
seconds = zeros(numel(files), 1);
outputChars = zeros(numel(files), 1);
message = strings(numel(files), 1);

for k = 1:numel(files)
    scriptPath = fullfile(files(k).folder, files(k).name);
    scriptName(k) = string(files(k).name);
    relativePath(k) = string(strrep(scriptPath, [projectRoot filesep], ""));

    timer = tic;
    try
        captured = run_script_isolated(scriptPath);
        status(k) = "PASS";
        message(k) = "";
    catch ME
        captured = "";
        status(k) = "FAIL";
        message(k) = string(ME.message);
    end
    seconds(k) = toc(timer);
    outputChars(k) = strlength(string(captured));
    close all force;

    fprintf("%-5s | %7.2fs | %s\n", status(k), seconds(k), relativePath(k));
    if status(k) == "FAIL"
        fprintf("       %s\n", message(k));
    end
end

results = table(scriptName, relativePath, status, seconds, outputChars, message);
disp(results);

if any(status == "FAIL")
    error("One or more scripts failed. See results table above.");
end
end

function captured = run_script_isolated(scriptPath)
% Keep script-level clear/clc commands away from the main runner workspace.
captured = evalc("run(scriptPath);");
end
