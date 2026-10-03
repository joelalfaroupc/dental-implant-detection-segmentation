% Academic project: Joel Alfaro and Daniel Pastor. See README for data and evaluation limits.
clc; clear; close all;
rng(42); % New export only: original split used unseeded rand().

% CONFIGURACIÓN
carpeta_origen = "Implantes";      
carpeta_salida = "dataset_final";  
exportar_datos = true;             

num_imagenes = 200;  

% Configuración de visualización 
implantes_por_figura = 4;  % Se abrirá una ventana cada 4 implantes
contador_visual = 0;       % Contador interno de procesadas

% Crear estructura de carpetas
if exportar_datos
    if exist(carpeta_salida, 'dir')
        error('Output directory already exists. Choose a new carpeta_salida; existing data are preserved.');
    end
    splits = {'train', 'val', 'test'};
    tipos  = {'images', 'masks', 'labels'};
    for k = 1:length(splits)
        for j = 1:length(tipos)
            mkdir(fullfile(carpeta_salida, splits{k}, tipos{j}));
        end
    end
    fprintf('Directorios creados en "%s".\n', carpeta_salida);
end

% BUCLE PRINCIPAL
fprintf('Iniciando procesamiento...\n');

for i = 1:num_imagenes
    nombre_archivo = sprintf('%d.jpg', i);
    % Leer imagen
    img_original = imread(fullfile(carpeta_origen, nombre_archivo));    
    img_gris = rgb2gray(img_original);
    
    % A) CALCULAR MÁSCARA
    mascara = calcular_mascara(img_gris);
    
    % B) OBTENER BOUNDING BOX
    bbox = obtener_bbox(mascara);
    if isempty(bbox)
        error('No implant component found for %s; inspect the thresholding result.', nombre_archivo);
    end
    
    % C) VISUALIZACIÓN
    contador_visual = contador_visual + 1;
    
    % Hueco de la ventana en el que toca mostrar
    indice_en_hoja = mod(contador_visual - 1, implantes_por_figura) + 1;
    
    % Si es el primero del lote (1, 5, 9...), creamos ventana nueva
    if indice_en_hoja == 1     
    num_lote = ceil(contador_visual/implantes_por_figura);
    
    figure('Name', sprintf('Lote %d (Img %d)', num_lote, i), ... 
           'Color', 'w', ...
           'NumberTitle', 'off', ...
           'Position', [50, 50, 1000, 900]);
    end
    
    % Panel Izquierdo: Máscara
    subplot(implantes_por_figura, 2, (indice_en_hoja * 2) - 1);
    imshow(mascara);
    title(sprintf('%s - Máscara', nombre_archivo), 'Interpreter', 'none', 'FontSize', 8);
    
    % Panel Derecho: Detección
    subplot(implantes_por_figura, 2, indice_en_hoja * 2);
    imshow(img_original); hold on;
    rectangle('Position', bbox, 'EdgeColor', 'g', 'LineWidth', 2);
    title('Detección', 'FontSize', 8);
    hold off;
        
    % D) EXPORTACIÓN DE DATOS
    if exportar_datos
        r = rand(); 
        if r < 0.70, split = 'train'; elseif r < 0.85, split = 'val'; else, split = 'test'; end % split de datasets (70,15,15)
        
        copyfile(fullfile(carpeta_origen, nombre_archivo), fullfile(carpeta_salida, split, 'images', nombre_archivo));
        
        [~, n, ~] = fileparts(nombre_archivo);
        nombre_mask = [n '.png'];
        imwrite(uint8(mascara) * 255, fullfile(carpeta_salida, split, 'masks', nombre_mask));
        % formato para Yolo
        [H, W, ~] = size(img_original);
        bx = bbox(1); by = bbox(2); bw = bbox(3); bh = bbox(4);
        x_center = (bx + bw/2) / W;
        y_center = (by + bh/2) / H;
        w_norm   = bw / W;
        h_norm   = bh / H;
        
        fid = fopen(fullfile(carpeta_salida, split, 'labels', [n '.txt']), 'w');
        fprintf(fid, '0 %.6f %.6f %.6f %.6f', x_center, y_center, w_norm, h_norm);
        fclose(fid);
    end
end

fprintf('Procesadas %d imágenes correctamente.\n', contador_visual);
% =========================================================
% FUNCIONES AUXILIARES
% =========================================================
% =========================================================
% SEGMENTACIÓN (MÁSCARA BINARIA)
% =========================================================
function BW_final = calcular_mascara(img)

    % Aplicamos un filtro gaussiano para suavizar imperfecciones
    I_smooth = imgaussfilt(img, 2.0);
    
    % Aumentamos el contraste 
    I_eq = imadjust(I_smooth); 
    
    % Primero, probamos con el algoritmo estándar de Otsu
    otsu_norm = graythresh(I_eq);
    otsu_idx = round(otsu_norm * 255) + 1;      
    [counts, ~] = imhist(I_eq);

    % Esta parte estaba pensada para imágenes como la 2, 3, 100 y 101, donde el
    % método de Otsu no define bien el umbral debido a la presencia de muchos
    % colores brillantes en el fondo. La idea era usar el valle más profundo a
    % la derecha del umbral de Otsu para separar mejor el fondo del implante.
   
    % El problema es que no supimos diferenciar este tipo de imágenes del resto
    % solo a partir del histograma. Al ajustar el parámetro altura_otsu para que
    % funcionara en estos casos, también afectaba negativamente a imágenes que
    % ya estaban bien segmentadas. Un valle poco pronunciado no implica
    % necesariamente que el umbral esté mal definido.

    % Aunque este método funciona bien en estos pocos casos si se aplica de
    % forma manual, decidimos no hacerlo porque en un caso real con muchas
    % imágenes no sería viable tratar los casos que dan error uno a uno sin una
    % forma automática de detectarlos.
    
    altura_otsu = counts(otsu_idx);
    
    idx_final = otsu_idx; % Por defecto confiamos en Otsu
    
    if altura_otsu >= 1400
        start_idx = otsu_idx + 40;
        end_idx   = min(255, otsu_idx + 120);
        
        if start_idx < end_idx
            mejor_idx = -1;
            menor_altura = Inf;
            
            for k = start_idx:end_idx
                val = counts(k);
                if (val < counts(k-1)) && (val < counts(k+1))
                    if val < menor_altura
                        menor_altura = val;
                        mejor_idx = k;
                    end
                end
            end
            
            if mejor_idx > 0 && menor_altura <= (altura_otsu * 1.3)
                idx_final = mejor_idx;
            end
        end
    end
    
    % Aplicamos el umbral
    umbral = idx_final - 1;
    BW_raw = I_eq > umbral;

    % Ponemos a negro (0) la primera y última fila, y la primera y última
    % columna, ya que en ciertos casos donde la imagen es muy brlllante en
    % los bordes, quedaba una linea fina que luego hacía que el
    % bounding box ocupara toda la imagen
   
    BW_raw([1 end], :) = 0;
    BW_raw(:, [1 end]) = 0;
    
    % Limpieza Geométrica
    BW_filled = imfill(BW_raw, 'holes');
   
    % Solo nos quedamos con estructuras verticales (Implantes)
    BW_vert = imopen(BW_filled, strel('line', 30, 90));

    % Usamos bwareafilt para quedarnos con el objeto más grande.
    BW_one_object = bwareafilt(BW_vert, 1);
    
    % Suavizamos los bordes
    BW_clean = imopen(BW_one_object, strel('disk', 5)); 
    BW_final = imclose(BW_clean, strel('disk', 5));    
end


% =========================================================
% SELECCIÓN DE BBOX 
% =========================================================
function bbox_out = obtener_bbox(mascara) 
    props = regionprops(mascara, 'BoundingBox');
    if isempty(props)
        bbox_out = [];
    else
        % Cogemos directamente la caja del único objeto que hay
        bbox_out = props(1).BoundingBox;
    end
end