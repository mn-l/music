function [P_peaks_idx, phi_e] = estimate_aoa_music(received_data, params)

    R = (received_data * received_data') / size(received_data, 2);

    % 特征值分解
    [E, D] = eig(R);
    eigenvalues = diag(D);
    [~, index] = sort(eigenvalues, 'descend');
    E = E(:, index);

    noise_subspace = E(:, 2:params.N_Tx);
    
    phi_list = linspace(-pi/2, pi/2, 1000)';  % 延迟列表

    d = params.antenna_distance;
    delta_d_list = (0:d:(params.N_Tx - 1) * d)'; 
    
    Omega_tau = exp(-1i * 2 * pi * delta_d_list * sin(phi_list'));
    sv_projection = abs(noise_subspace' * Omega_tau).^2;
    P_music = 1 ./ sum(sv_projection);  % 计算倒数并取绝对值
    P_MUSIC_max = max(P_music);
    P_MUSIC_dB = 10*log10(P_music/P_MUSIC_max);



    % 提取最大的两个峰值
    [P_peaks, P_peaks_idx] = findpeaks(P_MUSIC_dB);     % 提取峰值
[P_peaks, I] = sort(P_peaks, 'descend');    % 峰值降序排序
P_peaks_idx = P_peaks_idx(I);
P_peaks = P_peaks(1:params.N_signals);             % 提取前M个
P_peaks_idx = P_peaks_idx(1:params.N_signals);
phi_e = phi_list(P_peaks_idx)*180/pi;   % 估计方向
disp('信号源估计方向为（度）：');
disp(phi_e);
%%% 绘图
figure;
plot(phi_list*180/pi, P_MUSIC_dB, 'k', 'Linewidth', 2);
xlabel('\phi (deg)');
ylabel('Spectrum');
grid on;
hold on;
plot(phi_e, P_peaks, 'r.', 'MarkerSize', 25);
hold on;
for idx = 1:params.N_signals
    text(phi_e(idx)+3, P_peaks(idx), sprintf('%0.1f°', phi_e(idx)));
end

end
