function excel_csv_converter_gui
    % Crear una interfaz gráfica simple
    f = figure('Name', 'Conversión Excel/CSV', 'NumberTitle', 'Off', 'Position', [114, 131, 734, 482]);
    
    % Cambiar el color de fondo de la ventana (por ejemplo, gris claro)
    f.Color = '#108C44';  % RGB para gris claro
    
    % Cargar el logotipo JPEG como una matriz
    logoImage = imread('UVG.jpg'); 
    % Mostrar el logotipo en un componente 'axes'
    logoAxes = axes('Parent', f, 'Position', [0.1, 0.7, 0.8, 0.3]); % Ajusta la posición y el tamaño según tus necesidades
    imshow(logoImage, 'Parent', logoAxes);
    
    % Agregar una descripción en texto
    descriptionText = uicontrol('Style', 'text', 'Position', [84, 287, 560, 50], ...
        'String', 'Esta aplicación te permite convertir archivos entre formatos Excel (XLSX) y CSV o de texto (TXT) a CSV. Selecciona el tipo de conversión y el archivo que deseas convertir.', ...
        'BackgroundColor', '#108C44');  % Color transparente para el fondo
    
    % Crear una lista desplegable para seleccionar el tipo de archivo
    fileTypeList = uicontrol('Style', 'popupmenu', 'String', {'XLSX', 'TXT'}, 'Position', [138, 244, 90, 30], 'Callback', @fileTypeSelected);
    uicontrol('Style', 'text', 'String', 'Tipo de Archivo:', 'Position', [39, 249, 80, 30]);
    
    % Crear un grupo de radio buttons para seleccionar el tipo de conversión
    conversionTypeGroup = uibuttongroup('Position', [20, 100, 150, 70], 'Title', 'Tipo de Conversión');
    uicontrol(conversionTypeGroup, 'Style', 'radiobutton', 'String', 'A CSV', 'Position', [10, 40, 120, 20], 'Tag', 'toCsv');
    
    % Lista desplegable para seleccionar la hoja de Excel
    sheetList = uicontrol('Style', 'popupmenu', 'String', {}, 'Position', [491, 121, 130, 30], 'Enable', 'off');
    uicontrol('Style', 'text', 'String', 'Seleccionar Hoja:', 'Position', [351, 124, 120, 30]);
    
    % Botón para seleccionar el archivo
    uicontrol('Style', 'pushbutton', 'String', 'Seleccionar Archivo', 'Position', [172, 177, 150, 30], 'Callback', @selectFile);

    % Texto para mostrar el archivo seleccionado
    selectedFileText = uicontrol('Style', 'text', 'Position', [351, 177, 280, 30]);

    % Botón para realizar la conversión
    uicontrol('Style', 'pushbutton', 'String', 'Convertir', 'Position', [169, 71, 150, 30], 'Callback', @convert);
    
    % Actualizar la lista de hojas cuando se selecciona el archivo
    function updateSheetList(filePath)
        [~, sheetNames] = xlsfinfo(filePath);
        set(sheetList, 'String', sheetNames);
    end
    
    % Función para manejar la selección del tipo de archivo
    function fileTypeSelected(~, ~)
        fileType = get(fileTypeList, 'Value');
        if fileType == 1
            set(sheetList, 'Enable', 'on');
        else
            set(sheetList, 'Enable', 'off');
        end
    end

    % Función para seleccionar el archivo
    function selectFile(~, ~)
        fileType = get(fileTypeList, 'Value');
        if fileType == 1
            [fileName, filePath] = uigetfile({'*.xlsx'}, 'Selecciona un archivo XLSX');
        elseif fileType == 2
            [fileName, filePath] = uigetfile({'*.txt'}, 'Selecciona un archivo TXT');
        else
            msgbox('Selecciona un tipo de archivo primero.', 'Error', 'error');
            return;
        end
        
        if fileName
            selectedFileText.String = fileName;
            setappdata(f, 'fileToConvert', fullfile(filePath, fileName));
            
            % Actualizar la lista de hojas si se selecciona un archivo XLSX
            if fileType == 1
                updateSheetList(fullfile(filePath, fileName));
            end
        end
    end

    % Función para realizar la conversión
    function convert(~, ~)
        selectedConversion = get(get(conversionTypeGroup, 'SelectedObject'), 'Tag');
        if isempty(selectedConversion)
            msgbox('Selecciona un tipo de conversión primero.', 'Error', 'error');
            return;
        end

        fileToConvert = getappdata(f, 'fileToConvert');
        if isempty(fileToConvert)
            msgbox('Selecciona un archivo primero.', 'Error', 'error');
            return;
        end
        
        if strcmp(selectedConversion, 'toCsv')
            if endsWith(fileToConvert, '.xlsx')
                % Leer los datos de la hoja seleccionada
                [~, sheetNames] = xlsfinfo(fileToConvert);
                selectedSheetIndex = get(sheetList, 'Value');
                selectedSheetName = sheetNames{selectedSheetIndex};
                data = xlsread(fileToConvert, selectedSheetName);
                
                [csvFileName, csvPath] = uiputfile('*.csv', 'Guardar como archivo CSV');
                if csvFileName
                    csvFile = fullfile(csvPath, csvFileName);
                    writematrix(data, csvFile);
                    msgbox(['La conversión a CSV se ha completado. El archivo se ha guardado como ' csvFileName], 'Éxito', 'help');
                end
            elseif endsWith(fileToConvert, '.txt')
                [csvFileName, csvPath] = uiputfile('*.csv', 'Guardar como archivo CSV');
                if csvFileName
                    csvFile = fullfile(csvPath, csvFileName);
                    % Leer el contenido del archivo de texto y guardarlo en el archivo CSV
                    blockSize = 8192; % Puedes ajustar según sea necesario
                    fidIn = fopen(fileToConvert, 'r');
                    fidOut = fopen(csvFile, 'w');
                    
                    try
                        while ~feof(fidIn)
                            blockData = fread(fidIn, blockSize, 'char=>char')';
                            fprintf(fidOut, '%s', blockData);
                        end
                        msgbox(['La conversión a CSV se ha completado. El archivo se ha guardado como ' csvFileName], 'Éxito', 'help');
                    catch
                        errordlg('Error al convertir el archivo. Asegúrate de que el formato del archivo de texto sea adecuado.', 'Error');
                    end
                    
                    fclose(fidIn);
                    fclose(fidOut);
                end
            end
        end
    end

    % Mostrar la interfaz gráfica
    movegui(f, 'center');
end
