function [data] = hdf5plot(filename, xnormalize, ynormalize, ...
        t, x, y, output)
    names = h5read(filename, "/Data/Channel names");
    %disp(names.name);
    data = squeeze(h5read(filename, "/Data/Data"));

    h = figure;
    plot(data(1, :)/xnormalize, data(2, :)/ynormalize);
    title(t, "Interpreter", "LaTeX");
    xlim([min(data(1, :)) max(data(1, :))]);
    xlabel(x, "Interpreter", "LaTeX");
    ylabel(y, "Interpreter", "LaTeX");

    set(h, "Units", "Inches");
    pos = get(h, "Position");
    set(h, "PaperPositionMode", "Auto", "PaperUnits", "Inches", ...
        "PaperSize", [pos(3), pos(4)]);
    print(h, output, "-dpdf", "-r300");
end