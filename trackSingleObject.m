% ¿¨¶ûÂüÂË²¨¸ú×ÙÀý×Ó
function [adparam, others] = trackSingleObject(param,adparam)  %+isTrackInitialized,detectedLocation,isObjectDetected
if ~adparam.isTrackInitialized
    if adparam.isObjectDetected
        initialLocation = computeInitialLocation(param,adparam.detectedLocation);
        adparam.kalmanFilter = configureKalmanFilter(param.motionModel, ...
            initialLocation, param.initialEstimateError, ...
            param.motionNoise, param.measurementNoise);
        adparam.isTrackInitialized = true;
        others.trackedLocation = correct(adparam.kalmanFilter, adparam.detectedLocation);
        others.label = 'Initial';
    else
        others.trackedLocation = [];
        others.label = '';
    end
else
    if adparam.isObjectDetected % The ball was detected.
        predict(adparam.kalmanFilter);
        others.trackedLocation = correct(adparam.kalmanFilter, adparam.detectedLocation);
        others.label = 'Corrected';
    else % The ball was missing.
        others.trackedLocation = predict(adparam.kalmanFilter);
        others.label = 'Predicted';
    end
end
    function loc = computeInitialLocation(param, detectedLocation)
        if strcmp(param.initialLocation, 'Same as first detection')
            loc = detectedLocation;
        else
            loc = param.initialLocation;
        end
    end
end
