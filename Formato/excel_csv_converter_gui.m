function excel_csv_converter_gui
    % Crear una interfaz gráfica simple
    f = figure('Name', 'Conversión Excel/CSV', 'NumberTitle', 'Off', 'Position', [100, 100, 600, 400]);
    
    % Cambiar el color de fondo de la ventana 
    f.Color = '#108C44';  % RGB para verde
    
     % Cargar el logotipo JPEG como una matriz
    logoImage = imread('UVG.jpg'); 
    % Mostrar el logotipo en un componente 'axes'
    logoAxes = axes('Parent', f, 'Position', [0.1, 0.7, 0.8, 0.3]); % Ajusta la posición y el tamaño según tus necesidades
    imshow(logoImage, 'Parent', logoAxes);
    
    % Agregar una descripción en texto
    descriptionText = uicontrol('Style', 'text', 'Position', [20, 200, 560, 50], ...
        'String', 'Esta aplicación te permite convertir archivos entre formatos Excel (XLSX) y CSV. Selecciona el tipo de conversión y el archivo que deseas convertir.', ...
        'BackgroundColor', '#108C44');  % Color transparente para el fondo
    
    % Crear un grupo de radio buttons para seleccionar el tipo de conversión
    conversionTypeGroup = uibuttongroup('Position', [20, 100, 150, 70], 'Title', 'Tipo de Conversión');
    uicontrol(conversionTypeGroup, 'Style', 'radiobutton', 'String', 'Excel a CSV', 'Position', [10, 40, 120, 20], 'Tag', 'excelToCsv');
    uicontrol(conversionTypeGroup, 'Style', 'radiobutton', 'String', 'CSV a Excel', 'Position', [10, 10, 120, 20], 'Tag', 'csvToExcel');

    % Botón para seleccionar el archivo
    uicontrol('Style', 'pushbutton', 'String', 'Seleccionar Archivo', 'Position', [100, 150, 150, 30], 'Callback', @selectFile);

    % Texto para mostrar el archivo seleccionado
    selectedFileText = uicontrol('Style', 'text', 'Position', [300, 150, 200, 30]);

    % Botón para realizar la conversión
    uicontrol('Style', 'pushbutton', 'String', 'Convertir', 'Position', [100, 50, 150, 30], 'Callback', @convert);
    
    % Agregar una lista desplegable para seleccionar la hoja de Excel
    sheetList = uicontrol('Style', 'popupmenu', 'String', {}, 'Position', [350, 100, 130, 30]);
    uicontrol('Style', 'text', 'String', 'Seleccionar Hoja:', 'Position', [200, 100, 120, 30]);
    
    % Actualizar la lista de hojas cuando se selecciona el archivo
    function updateSheetList(filePath)
        [~, sheetNames] = xlsfinfo(filePath);
        set(sheetList, 'String', sheetNames);
    end

    % Función para seleccionar el archivo
    function selectFile(~, ~)
        [fileName, filePath] = uigetfile({'*.xlsx', '*.csv'}, 'Selecciona el archivo');
        if fileName
            selectedFileText.String = fileName;
            setappdata(f, 'fileToConvert', fullfile(filePath, fileName));
            
            % Actualizar la lista de hojas
            updateSheetList(fullfile(filePath, fileName));
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
        
        selectedSheetIndex = get(sheetList, 'Value');
        if isempty(selectedSheetIndex)
            msgbox('Selecciona una hoja de Excel primero.', 'Error', 'error');
            return;
        end

        if strcmp(selectedConversion, 'excelToCsv')
            % Leer los datos de la hoja seleccionada
            [~, sheetNames] = xlsfinfo(fileToConvert);
            selectedSheetName = sheetNames{selectedSheetIndex};
            data = xlsread(fileToConvert, selectedSheetName);
            
            [csvFileName, csvPath] = uiputfile('*.csv', 'Guardar como archivo CSV');
            if csvFileName
                csvFile = fullfile(csvPath, csvFileName);
                writematrix(data, csvFile);
                msgbox(['La conversión de Excel a CSV se ha completado. El archivo se ha guardado como ' csvFileName], 'Éxito', 'help');
            end
        elseif strcmp(selectedConversion, 'csvToExcel')
            data = csvread(fileToConvert);
            [excelFileName, excelPath] = uiputfile('*.xlsx', 'Guardar como archivo Excel');
            if excelFileName
                excelFile = fullfile(excelPath, excelFileName);
                xlswrite(excelFile, data);
                msgbox(['La conversión de CSV a Excel se ha completado. El archivo se ha guardado como ' excelFileName], 'Éxito', 'help');
            end
        end
    end

    % Mostrar la interfaz gráfica
    movegui(f, 'center');
end
