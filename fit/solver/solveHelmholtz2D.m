function [ebow, relRes] = solveMQSF(msh, eps, mui, jsbow, f, bc)

    % Anzahl der Rechenpunkte des Gitters
    np = msh.np;

    % TODO: 2D top matrices
    [c, s, st] = createTopMats(msh);

    % TODO: 2D geometry matrices
    [ds, dst, da, dat] = createGeoMats(msh);

    % TODO: 2D material matrices
    meps = createMeps(msh, ds, da, dat, eps, bc);
    mmui = createMmui(msh, ds, dst, da, mui, bc);

    % Berechnung der Kreisfrequenz
    omega = 2*pi*f;

    % Berechnung Systemmatrix A und rechte Seite rhs
    idx = setdiff(1:3*np, getGhostEdges(msh));
    AF = -st*mmui*st' + omega^2*meps;
    A = AF(idx, idx);
    rhs = 1j*omega*jsbow(idx);

    % solve equation
    ebow = zeros(np, 1);
    [ebow_deflate, flag, relRes, iter, resVec] = gmres(A, rhs, 20, 1e-10, 1000); % TODO: direct vs iteratve?
    ebow(idx) = ebow_deflate;
    if flag == 0
      fprintf('gmres(20): converged at iteration %2d to a solution with relative residual %d.\n',iter,relRes);
    else
      error('gmres(20): some error ocurred, please check flag output.')
    end
    relRes = resVec./norm(rhs);

    % TODO: post processing
end