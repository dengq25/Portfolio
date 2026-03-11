%% 1) Event labels + state

% STIMULUS event codes
P2C     = 'ool-1';  % border Go: Possible -> Certain
Go_Cert = 'ool-2';  % Go in Certain block
C2C     = 'ool-3';  % border Go: Certain -> Certain
C2P     = 'ool-4';  % border Go: Certain -> Possible (C2P)
Go_Poss = 'ool-5';  % Go in Possible block
P2P     = 'ool-6';  % border Go: Possible -> Possible (P2P)
NoGo    = 'ool-7';  % NoGo in Possible block

% Groupings
PossibleBorders = {C2P, P2P};
GoInPossible    = {Go_Poss, C2P, P2P};
AllBorders      = {P2C, C2C, C2P, P2P};

% State variables
currentCueType  = '';
goCountAfterCue = 0;
inNoGoEpisode   = false;
goCountAfterNoGo = 0;

nEvents = numel(EEG.event);

%% 2) Walk events & index Go's

for i = 1:nEvents
    
    thisType = EEG.event(i).type;
    if isnumeric(thisType)
        thisType = num2str(thisType);
    end
    
    isBorder   = ismember(thisType, AllBorders);
    isGoInPoss = ismember(thisType, GoInPossible);
    isNoGo     = strcmp(thisType, NoGo);
    
    EEG.event(i).cueEpisodeType = '';
    EEG.event(i).cueGoIndex     = [];
    EEG.event(i).noGoGoIndex    = [];
    
    % 2.1 Borders
    if isBorder
        currentCueType  = '';
        goCountAfterCue = 0;
        
        inNoGoEpisode    = false;
        goCountAfterNoGo = 0;
        
        if strcmp(thisType, C2P)
            currentCueType  = 'C2P';
            goCountAfterCue = 1;
            EEG.event(i).cueEpisodeType = 'C2P';
            EEG.event(i).cueGoIndex     = goCountAfterCue;
            
        elseif strcmp(thisType, P2P)
            currentCueType  = 'P2P';
            goCountAfterCue = 1;
            EEG.event(i).cueEpisodeType = 'P2P';
            EEG.event(i).cueGoIndex     = goCountAfterCue;
        end
        
        continue;
    end
    
    % 2.2 NoGo
    if isNoGo
        inNoGoEpisode    = true;
        goCountAfterNoGo = 0;
        continue;
    end
    
    % 2.3 Go_Poss (non-border Go in Possible)
    if isGoInPoss && strcmp(thisType, Go_Poss)
        
        if ~isempty(currentCueType)
            goCountAfterCue = goCountAfterCue + 1;
            EEG.event(i).cueEpisodeType = currentCueType;
            EEG.event(i).cueGoIndex     = goCountAfterCue;
        end
        
        if inNoGoEpisode
            goCountAfterNoGo = goCountAfterNoGo + 1;
            EEG.event(i).noGoGoIndex = goCountAfterNoGo;
        end
        
        continue;
    end
    
    % others ignored
    
end

%% 3) Create text labels
for i = 1:nEvents
    
    % ----- Cue-based label: GoN-C2P / GoN-P2P -----
    cueLabel = '';
    if ~isempty(EEG.event(i).cueEpisodeType) && ~isempty(EEG.event(i).cueGoIndex)
        cueLabel = sprintf('Go%d-%s', ...
                           EEG.event(i).cueGoIndex, ...
                           EEG.event(i).cueEpisodeType);
    end
    EEG.event(i).cueLabel = cueLabel;
    
    % ----- NoGo-based label: GoN-NoGo -----
    noGoLabel = '';
    if ~isempty(EEG.event(i).noGoGoIndex)
        noGoLabel = sprintf('Go%d-NoGo', EEG.event(i).noGoGoIndex);
    end
    EEG.event(i).noGoLabel = noGoLabel;

    % ----- Label actual NoGo trials themselves -----
    baseLabel = '';
    if strcmp(EEG.event(i).type, NoGo)
        baseLabel = 'NoGo';
    elseif ~isempty(cueLabel)
        baseLabel = cueLabel;
    elseif ~isempty(noGoLabel)
        baseLabel = noGoLabel;
    end
    EEG.event(i).baseLabel = baseLabel;
    
end

%% 3b) Use baseLabel as the visible event TYPE
for i = 1:nEvents
    if ~isempty(EEG.event(i).baseLabel)
        % keep original ool-* code in a separate field
        EEG.event(i).origType = EEG.event(i).type;
        % replace with your descriptive label
        EEG.event(i).type     = EEG.event(i).baseLabel;
    end
end

%% 4) Quick inspection of first N events
nShow = min(80, nEvents);
fprintf('\nIdx\tType\t\tCueType\tCueIdx\tCueLabel\t\tNoGoIdx\tNoGoLabel\n');
fprintf('--------------------------------------------------------------------------\n');

for i = 1:nShow
    
    thisType = EEG.event(i).type;
    if isnumeric(thisType), thisType = num2str(thisType); end
    
    cueType   = EEG.event(i).cueEpisodeType;
    cueIdx    = EEG.event(i).cueGoIndex;
    cueLabel  = EEG.event(i).cueLabel;
    noGoIdx   = EEG.event(i).noGoGoIndex;
    noGoLabel = EEG.event(i).noGoLabel;
    
    if isempty(cueType),   cueType   = '';  end
    if isempty(cueIdx),    cueIdx    = NaN; end
    if isempty(cueLabel),  cueLabel  = '';  end
    if isempty(noGoIdx),   noGoIdx   = NaN; end
    if isempty(noGoLabel), noGoLabel = '';  end
    
    fprintf('%3d\t%-8s\t%-4s\t%5.1f\t%-16s\t%5.1f\t%-16s\n', ...
        i, thisType, cueType, cueIdx, cueLabel, noGoIdx, noGoLabel);
end

disp('Event labeling complete.');
