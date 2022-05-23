function [returnData, X, Y, Z] = hdf5surf(filename, heatmap, ...
        xnormalize, ynormalize, znormalize, t, x, y, z, ...
        output, lambda, keepcols)

    names = h5read(filename, "/Data/Channel names");
    %disp(names.name);
    returnData = h5read(filename, "/Data/Data");

    if ~isstring(keepcols) || keepcols ~= "all"
        data = returnData(:, keepcols, :);
    else
        data = returnData;
    end

    X = squeeze(data(:, 1, :));
    Y = squeeze(data(:, 2, :));
    Z = squeeze(data(:, 3, :));

    Z = lambda(X, Y, Z);

    X = X / xnormalize;
    Y = Y / ynormalize;
    Z = Z / znormalize;


    h = figure;
    surf(X, Y, Z);
    title(t, "Interpreter", "LaTeX");
    xlim([min(X, [], "all") max(X, [], "all")]);
    ylim([min(Y, [], "all") max(Y, [], "all")]);
    xlabel(x, "Interpreter", "LaTeX");
    ylabel(y, "Interpreter", "LaTeX");

    if heatmap
        shading interp;
        colormap hot;
        c = colorbar;
        c.Label.String = z;
        c.Label.Interpreter = "LaTeX";
        c.Label.FontSize = 11;
        view(2);
    end

    set(h, "Units", "Inches");
    pos = get(h, "Position");
    set(h, "PaperPositionMode", "Auto", "PaperUnits", "Inches", ...
        "PaperSize", [pos(3), pos(4)]);
    print(h, output, "-dpdf", "-r300");
end