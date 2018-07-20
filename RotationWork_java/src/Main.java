import java.io.File;
import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
/*from  w  w  w .  j ava 2  s.c o  m*/
import javafx.application.Application;
import javafx.beans.property.SimpleStringProperty;
import javafx.beans.value.ChangeListener;
import javafx.beans.value.ObservableValue;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.embed.swing.SwingFXUtils;
import javafx.event.ActionEvent;
import javafx.event.EventHandler;
import javafx.geometry.*;
import javafx.geometry.Insets;
import javafx.scene.Scene;
import javafx.scene.SnapshotParameters;
import javafx.scene.control.*;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import javafx.scene.control.TextField;
import javafx.scene.control.cell.PropertyValueFactory;
import javafx.scene.effect.DropShadow;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.image.WritableImage;
import javafx.scene.input.MouseButton;
import javafx.scene.input.MouseEvent;
import javafx.scene.layout.*;
import javafx.scene.paint.Color;
import javafx.stage.*;
import javafx.util.Callback;
import javafx.util.StringConverter;

import javax.imageio.ImageIO;

public class Main extends Application {

    DropShadow shadow = new DropShadow();

    public int sizeX (int size) {
        int dpi = (int) Screen.getPrimary().getDpi();
        int designDpi = 157; // This DPI was when programmed on Lenovo E460 14" screen so I want to keep the same size;
        int tmp = (int) (( size * dpi ) / designDpi );
        return tmp;
    }

    public void stylCol (TableColumn tabCol, int width, String style, boolean sort, String property){
        tabCol.setCellValueFactory(
                new PropertyValueFactory<Rotation, String>(property));
        tabCol.setMinWidth(sizeX(width));
        tabCol.setMaxWidth(sizeX(width));
        tabCol.setStyle(style);
        tabCol.setSortable(sort);
    }

    public void stylBut (Button button, String content, int width, int height){
        button.setText(content);
        button.setPrefSize(sizeX(width),sizeX(height));
        button.setAlignment(Pos.CENTER);
        button.setStyle("-fx-font: " + sizeX(15) + "px Regular;");
    }

    public void stylLab (Label label, String content, int width, String position){
        label.setText(content);
        label.setPrefWidth(sizeX(width));
        label.setAlignment(Pos.valueOf(position));
        label.setStyle("-fx-font: " + sizeX(15) + "px Regular;");
    }

    public void stylTxt (TextField textfield, int width){
        textfield.setPrefWidth(sizeX(width));
        textfield.setAlignment(Pos.CENTER);
        textfield.setStyle("-fx-font: " + sizeX(15) + "px Regular;");
    }

    private void handleButtonEnter(MouseEvent event){
        ((Button) event.getTarget()).setEffect(shadow);
    }

    private void handleButtonExit(MouseEvent event){
        ((Button) event.getTarget()).setEffect(null);
    }

    private void handleTextFieldEnter(MouseEvent event){
        ((TextField) event.getTarget()).setEffect(shadow);
        ((TextField) event.getTarget()).setStyle("-fx-control-inner-background: #FFF1C4");
    }

    private void handleTextFieldExit(MouseEvent event){
        ((TextField) event.getTarget()).setEffect(null);
        ((TextField) event.getTarget()).setStyle("-fx-control-inner-background: #FFFFFF");
    }

    private void handleRadioEnter(MouseEvent event){
        ((RadioButton) event.getTarget()).setEffect(shadow);
    }

    private void handleRadioExit(MouseEvent event){
        ((RadioButton) event.getTarget()).setEffect(null);
    }

    private TableView<Rotation> table = new TableView<Rotation>(
    );

    private final ObservableList<Rotation> data =
            FXCollections.observableArrayList(
            );

    private Callback<DatePicker, DateCell> getDayCellFactory() {
        final Callback<DatePicker, DateCell> dayCellFactory = new Callback<DatePicker, DateCell>() {
            @Override
            public DateCell call(final DatePicker dp) {
                return new DateCell() {
                    @Override
                    public void updateItem(LocalDate item, boolean empty) {
                        super.updateItem(item, empty);

                        if (item.getDayOfWeek() == DayOfWeek.SATURDAY //
                                || item.getDayOfWeek() == DayOfWeek.SUNDAY) {
                            setDisable(false);
                            setStyle("-fx-background-color: #FFF68F;"); //#[6eb3e0, dbd7ba, A4D3EE]
                        }

                        if (item.isBefore(LocalDate.now().minusDays(199)) || item.isAfter(LocalDate.now().plusDays(199))) {
                            setDisable(true);
                            setStyle("-fx-background-color: #8B8682;"); //#[000000, 838B83]
                        }

                    }
                };
            }
        };
        return dayCellFactory;
    }

    int spcH = sizeX(10); int spcV = sizeX(10);
    int week = 7; int maxR = 24; int out = 0; int tableFont = 15;
    int appW = sizeX(850); int appH = sizeX(640);

    int vewtr; int ton; int toff; int mainON; int mainOFF;
    int[] trpNO; int[] timON; int[] sumON; int[] tmOFF; int[] smOFF; int[] coeF;

    String[] getOn; String[] gtOff; String[] weeK;
    String dateCustom = "d MMMM yyyy, EEEE";
    String checkWork; String checkOff;

    Boolean[] vewTR;

    Button glb = new Button("Proceed");

    Label podpis = new Label("Copyright " + "\u00A9" + " 2017 Zbigniew Karolczuk, Quick Solution!");
    Label tx = new Label("Select number of rotations do display:");
    Label dsply = new Label("View ");

    TextField tf = new TextField("6");
    TextField mon = new TextField("6"); TextField mof = new TextField("6");
    TextField tfON = new TextField("42"); TextField tfOFF = new TextField("42");

    Button b = new Button(); Button m = new Button(); Button m2 = new Button(); Button applY = new Button();
    Button plus = new Button(); Button minus = new Button(); Button plsVw = new Button(); Button mnsVw = new Button();
    Button plTRP = new Button(); Button mnTRP = new Button(); Button plsON = new Button(); Button mnsON = new Button();
    Button plOFF = new Button(); Button mnOFF = new Button(); Button printer = new Button();

    Label modTL = new Label(); Label modON = new Label(); Label modOF = new Label(); Label modTM = new Label();
    Label nodON = new Label(); Label nodOF = new Label(); Label nodTM = new Label(); Label rotNO = new Label();
    Label empty = new Label(); Label trp = new Label(); Label xon = new Label(); Label xof = new Label();

    ToggleGroup toogle = new ToggleGroup(); RadioButton radio1 = new RadioButton("Days"); RadioButton radio2 = new RadioButton("Weeks");

    Tooltip tooltip = new Tooltip();

    DatePicker dp = new DatePicker(LocalDate.now());

    private File lastPath;

    @Override
    public void start(Stage myStage) {

        Locale.setDefault(Locale.UK);

        TableColumn numberCol = new TableColumn("No");
        stylCol(numberCol, 50, "-fx-alignment: CENTER;", false, "rotationNo");

        TableColumn fromCol = new TableColumn("Rotation start");
        stylCol(fromCol, 250, "-fx-alignment: CENTER;", false, "rotationFrom");

        TableColumn untilCol = new TableColumn("Rotation finish");
        stylCol(untilCol, 250, "-fx-alignment: CENTER;", false, "rotationUntil");

        TableColumn tripCol = new TableColumn("Work");
        stylCol(tripCol, 125, "-fx-alignment: CENTER;", false, "periodWork");

        TableColumn offCol = new TableColumn("Off");
        stylCol(offCol, 125, "-fx-alignment: CENTER;", false, "periodOff");

        table.setEditable(true);
        table.setItems(data);
        table.getColumns().addAll(numberCol, fromCol, untilCol, tripCol, offCol);
        table.getStylesheets().add("Styles.css");
        table.setFixedCellSize(sizeX(45));
        table.setMinWidth(sizeX(820));
        table.setMaxWidth(sizeX(820));
        table.setMinHeight(sizeX(450));
        table.setMaxHeight(sizeX(450));

        tf.setPrefHeight(sizeX(31));
        tf.setMinWidth(sizeX(35));

        glb.setMinWidth(sizeX(180));
        glb.setMaxWidth(sizeX(180));
        glb.setAlignment(Pos.CENTER);
        glb.setStyle("-fx-font: " + sizeX(18) + "px \"Candara\";");
        dsply.setMinWidth(sizeX(100));
        dsply.setMaxWidth(sizeX(100));
        dsply.setAlignment(Pos.CENTER_RIGHT);
        dsply.setStyle("-fx-font: " + sizeX(18) + "px \"Candara\";");
        dsply.setTextFill(Color.AZURE);
        empty.setStyle("-fx-background-color: #336699;");
        empty.setPrefWidth(sizeX(200));

        dsply.setVisible(false);
        mnsVw.setVisible(false);
        plsVw.setVisible(false);

        podpis.setTextFill(Color.AZURE);
        podpis.setPrefWidth(sizeX(500));
        podpis.setAlignment(Pos.CENTER);

        tooltip.setText("contact me:  karolczuk.z@gmail.com");
        podpis.setTooltip(tooltip);

        BorderPane root = new BorderPane();

        HBox upBox = new HBox();
        upBox.setPadding(new Insets(sizeX(25), sizeX(12), sizeX(25), sizeX(12)));
        upBox.setSpacing(10);   // Gap between nodes
        upBox.setPrefSize(appW, sizeX(75));
        upBox.setStyle("-fx-background-color: #336699;");
        upBox.setAlignment(Pos.CENTER_LEFT);
        upBox.getChildren().addAll(dp, glb, dsply, mnsVw, plsVw);

        dp.setTranslateX(sizeX(228));
        glb.setTranslateX(sizeX(228));
        dsply.setTranslateX(sizeX(148+49));
        mnsVw.setTranslateX(sizeX(148+49));
        plsVw.setTranslateX(sizeX(148+48));

        VBox vbox = new VBox();
        vbox.setSpacing(0);
        vbox.setPadding(new Insets(sizeX(15), 0, sizeX(15), sizeX(15)));
        vbox.setAlignment(Pos.CENTER_LEFT);

        HBox doBox = new HBox();
        doBox.setPadding(new Insets(sizeX(11), sizeX(12), sizeX(11), sizeX(12)));
        doBox.setSpacing(sizeX(10));   // Gap between nodes
        doBox.setPrefSize(appW, sizeX(75));
        doBox.setStyle("-fx-background-color: #336699;" +
                "-fx-font: " + sizeX(18) + "px \"Candara\";"); //OldGood: [Calibri, Book Antiqua]
        doBox.setAlignment(Pos.CENTER);
        doBox.getChildren().addAll(podpis, printer);

        podpis.setAlignment(Pos.CENTER);
        podpis.setTranslateX(sizeX(37));
        printer.setTranslateX(sizeX(58));
        printer.setVisible(false);

        root.setTop(upBox);
        root.setCenter(vbox);
        root.setBottom(doBox);
        root.setPrefSize(appW, appH);

        Scene myScene = new Scene(root);

        myStage.setResizable(false);
        myStage.setScene(myScene);
        myStage.sizeToScene();

        myStage.setTitle("Calculate your work rotations");
        myStage.getIcons().add(new Image("files/calendar.jpg"));

        Callback<DatePicker, DateCell> dayCellFactory = this.getDayCellFactory();

        //////////////////////////////////////////////////////////////////////////////////

        Image load_apply = new Image(getClass().getResourceAsStream("files/apply.gif"));
        ImageView apply = new ImageView();
        apply.setImage(load_apply);
        apply.setFitWidth(sizeX(35));
        apply.setFitHeight(sizeX(35));
        applY.setGraphic(apply);

        Image load_printer = new Image(getClass().getResourceAsStream("files/printer.gif"));
        ImageView init_printer = new ImageView();
        init_printer.setImage(load_printer);
        init_printer.setFitWidth(sizeX(41));
        init_printer.setFitHeight(sizeX(41));
        printer.setGraphic(init_printer);
        printer.setStyle("-fx-background-color: #336699;");

        Image load_2plus = new Image(getClass().getResourceAsStream("files/2plus.gif"));
        ImageView init_plus = new ImageView();
        init_plus.setImage(load_2plus);
        init_plus.setFitWidth(sizeX(31));
        init_plus.setFitHeight(sizeX(31));

        plus.setGraphic(init_plus);
        plus.setStyle("-fx-background-color: #7BA3CA;");//#336699
        plus.setPadding(new Insets(sizeX(2),sizeX(2),sizeX(2),sizeX(2)));

        Image load_up = new Image(getClass().getResourceAsStream("files/down.gif"));
        ImageView init_up = new ImageView();
        init_up.setImage(load_up);
        init_up.setFitWidth(sizeX(31));
        init_up.setFitHeight(sizeX(31));

        plsVw.setGraphic(init_up);
        plsVw.setStyle("-fx-background-color: #E0E1C6;");
        plsVw.setPadding(new Insets(sizeX(2),sizeX(2),sizeX(2),sizeX(2)));

        Image load_2minus = new Image(getClass().getResourceAsStream("files/2minus.gif"));
        ImageView init_minus = new ImageView();
        init_minus.setImage(load_2minus);
        init_minus.setFitWidth(sizeX(31));
        init_minus.setFitHeight(sizeX(31));

        minus.setGraphic(init_minus);
        minus.setStyle("-fx-background-color: #7BA3CA;");//#336699,0E3E6C
        minus.setPadding(new Insets(sizeX(2),sizeX(2),sizeX(2),sizeX(2)));

        Image load_down = new Image(getClass().getResourceAsStream("files/up.gif"));
        ImageView init_down = new ImageView();
        init_down.setImage(load_down);
        init_down.setFitWidth(sizeX(31));
        init_down.setFitHeight(sizeX(31));

        mnsVw.setGraphic(init_down);
        mnsVw.setStyle("-fx-background-color: #E0E1C6;");
        mnsVw.setPadding(new Insets(sizeX(2),sizeX(2),sizeX(2),sizeX(2)));

        ImageView init_plTrp = new ImageView();
        init_plTrp.setImage(load_2plus);
        init_plTrp.setFitWidth(sizeX(31));
        init_plTrp.setFitHeight(sizeX(31));
        plTRP.setGraphic(init_plTrp);
        plTRP.setPadding(new Insets(sizeX(2), sizeX(2), sizeX(2), sizeX(2)));
        plTRP.setStyle("-fx-background-color: #7BA3CA;");//#336699

        ImageView init_mnTrp = new ImageView();
        init_mnTrp.setImage(load_2minus);
        init_mnTrp.setFitWidth(sizeX(31));
        init_mnTrp.setFitHeight(sizeX(31));
        mnTRP.setGraphic(init_mnTrp);
        mnTRP.setPadding(new Insets(sizeX(2), sizeX(2), sizeX(2), sizeX(2)));
        mnTRP.setStyle("-fx-background-color: #7BA3CA;");//#336699

        Image load_plus = new Image(getClass().getResourceAsStream("files/plus.gif"));
        Image load_minus = new Image(getClass().getResourceAsStream("files/minus.gif"));

        ImageView init_plsOn = new ImageView();
        init_plsOn.setImage(load_plus);
        init_plsOn.setFitWidth(sizeX(27));
        init_plsOn.setFitHeight(sizeX(27));
        plsON.setGraphic(init_plsOn);
        plsON.setPadding(new Insets(sizeX(4), sizeX(4), sizeX(4), sizeX(4)));

        ImageView init_mnsOn = new ImageView();
        init_mnsOn.setImage(load_minus);
        init_mnsOn.setFitWidth(sizeX(27));
        init_mnsOn.setFitHeight(sizeX(27));
        mnsON.setGraphic(init_mnsOn);
        mnsON.setPadding(new Insets(sizeX(4), sizeX(4), sizeX(4), sizeX(4)));

        ImageView init_plOff = new ImageView();
        init_plOff.setImage(load_plus);
        init_plOff.setFitWidth(sizeX(27));
        init_plOff.setFitHeight(sizeX(27));
        plOFF.setGraphic(init_plOff);
        plOFF.setPadding(new Insets(sizeX(4), sizeX(4), sizeX(4), sizeX(4)));

        ImageView init_mnOff = new ImageView();
        init_mnOff.setImage(load_minus);
        init_mnOff.setFitWidth(sizeX(27));
        init_mnOff.setFitHeight(sizeX(27));
        mnOFF.setGraphic(init_mnOff);
        mnOFF.setPadding(new Insets(sizeX(4), sizeX(4), sizeX(4), sizeX(4)));

        //////////////////////////////////////////////////////////////////////////////////


        dp.setConverter(new StringConverter<LocalDate>()
        {
            private DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("d MMM yyyy");

            @Override
            public String toString(LocalDate localDate)
            {
                if(localDate==null)
                    return "";
                return dateTimeFormatter.format(localDate);
            }

            @Override
            public LocalDate fromString(String dateString)
            {
                if(dateString==null || dateString.trim().isEmpty())
                {
                    return null;
                }
                return LocalDate.parse(dateString,dateTimeFormatter);
            }
        });

        dp.setStyle("-fx-font: " + sizeX(18) + "px \"Candara\";");
        dp.setPromptText("Select date");
        dp.getStylesheets().add("Styles.css");
        dp.setPrefWidth(sizeX(180));
        dp.setDayCellFactory(dayCellFactory);
        dp.setEditable(false);
        dp.setShowWeekNumbers(true);
        dp.setFocusTraversable(false);

        stylTxt(tf,40);
        stylTxt(mon, 40);
        stylTxt(mof, 40);
        stylTxt(tfON, 60);
        stylTxt(tfOFF, 60);

        stylBut(m, "Apply" ,90, 30);

        tx.setStyle("-fx-font: " + sizeX(15) + "px Regular;");

        stylLab(trp, tf.getText(), 20, "CENTER"); trp.setTextFill(javafx.scene.paint.Color.AZURE);
        stylLab(xon, "", 20, "CENTER");
        stylLab(xof, "", 20, "CENTER");
        stylLab(modTL, "Change rotation:", 130, "CENTER_RIGHT"); modTL.setTextFill(javafx.scene.paint.Color.AZURE);
        stylLab(modON, "Period at work:", 130, "CENTER_RIGHT");
        stylLab(modOF, "Period at home:", 130, "CENTER_RIGHT");
        stylLab(modTM, "Choose time unit:", 130, "CENTER"); modTM.setTextFill(javafx.scene.paint.Color.AZURE);
        stylLab(rotNO, "How many rotations to display?", 273, "CENTER"); rotNO.setTextFill(javafx.scene.paint.Color.AZURE); //minus.setStyle("-fx-background-color: #FFFFFF;");//#336699,0E3E6C
        stylLab(nodON, "Period at work:",130, "CENTER_RIGHT");
        stylLab(nodOF, "Period at home:", 130, "CENTER_RIGHT");
        stylLab(nodTM, "", 130, "CENTER_RIGHT"); nodTM.setTextFill(javafx.scene.paint.Color.AZURE);

        radio1.setToggleGroup(toogle);
        radio1.setUserData(new String("day"));
        radio1.setStyle("-fx-font: " + sizeX(15) + "px Regular;");
        radio1.setTextFill(javafx.scene.paint.Color.AZURE);

        radio1.setOnMouseEntered(this::handleRadioEnter);
        radio1.setOnMouseExited(this::handleRadioExit);

        radio2.setSelected(true);
        radio2.setToggleGroup(toogle);
        radio2.setUserData(new String("week"));
        radio2.setStyle("-fx-font: " + sizeX(15) + "px Regular;");
        radio2.setTextFill(javafx.scene.paint.Color.AZURE);

        radio2.setOnMouseEntered(this::handleRadioEnter);
        radio2.setOnMouseExited(this::handleRadioExit);

        /*
          ###############################################
             Object listeners balow and execute codes
          ###############################################
        */

        dp.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {
                if(out == 1) m.fire();
            }
        });

        dp.addEventHandler(MouseEvent.MOUSE_ENTERED,
                new EventHandler<MouseEvent>() {
                    @Override
                    public void handle(MouseEvent e) {
                        dp.setEffect(shadow);
                    }
                });

        dp.addEventHandler(MouseEvent.MOUSE_EXITED,
                new EventHandler<MouseEvent>() {
                    @Override
                    public void handle(MouseEvent e) {
                        dp.setEffect(null);
                    }
                });

        tripCol.setCellFactory(column -> {
            return new TableCell<Rotation, String>() {
                @Override
                protected void updateItem(String item, boolean empty) {
                    super.updateItem(item, empty); //This is mandatory

                    setStyle("-fx-font: " + sizeX(tableFont) + "px Regular;" +
                            "-fx-alignment: CENTER;");

                    if (item == null || empty) {
                        setText(null);

                    } else {
                        setText(item);
                        Rotation auxTripRotation = getTableView().getItems().get(getIndex());
                        TableRow currentTripRow = getTableRow();

                        if (auxTripRotation.getPeriodWork().equals(checkWork)) {
                            currentTripRow.setStyle(null);

                        } else {
                            currentTripRow.setStyle("-fx-control-inner-background: #FFF68F");

                        }
                    }
                }
            };
        });

        offCol.setCellFactory(column -> {
            return new TableCell<Rotation, String>() {
                @Override
                protected void updateItem(String item, boolean empty) {
                    super.updateItem(item, empty); //This is mandatory

                    setStyle("-fx-font: " + sizeX(tableFont) + "px Regular;" +
                            "-fx-alignment: CENTER;");

                    if (item == null || empty) {
                        setText(null);

                    } else {
                        setText(item);
                        Rotation auxOffRotation = getTableView().getItems().get(getIndex());
                        TableRow currentOffRow = getTableRow();

                        if (auxOffRotation.getPeriodOff().equals(checkOff)) {
                            if(!currentOffRow.getStyle().contains("FFF68F")){
                                currentOffRow.setStyle(null);
                            }

                        } else {
                            currentOffRow.setStyle("-fx-control-inner-background: #FFF68F");
                        }
                    }

                }
            };
        });

        table.setRowFactory(tv -> {
            TableRow<Rotation> row = new TableRow<>();
            row.setOnMouseClicked(event -> {
                if (! row.isEmpty() && event.getButton()== MouseButton.PRIMARY
                        && event.getClickCount() == 1) {

                    Rotation clickedRow = row.getItem();
                    trp.setText(clickedRow.getRotationNo());
                }
            });
            return row ;

        });

        // PROGRAMING BUTTONS BEHAVIOUR:

        plus.setOnMouseEntered(this::handleButtonEnter);
        plus.setOnMouseExited(this::handleButtonExit);
        plus.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {

                int inew = Integer.valueOf(tf.getText()) + 1;
                String snew = String.valueOf(inew);
                tf.setText(snew);

                if (Integer.valueOf(snew) > Integer.valueOf(tf.getText())){
                    trp.setText(tf.getText());
                } else{
                    trp.setText(snew);
                }

            }
        });

        minus.setOnMouseEntered(this::handleButtonEnter);
        minus.setOnMouseExited(this::handleButtonExit);
        minus.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {
                int inew = Integer.valueOf(tf.getText()) - 1;
                String snew = String.valueOf(inew);
                tf.setText(snew);

                if (Integer.valueOf(snew) < 1){
                    trp.setText("1");
                } else{
                    trp.setText(snew);
                }

            }
        });

        plsVw.setOnMouseEntered(this::handleButtonEnter);
        plsVw.setOnMouseExited(this::handleButtonExit);
        plsVw.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {

                if (vewtr < maxR) {
                    vewtr = vewtr + 1;

                    trp.setText(String.valueOf(vewtr));
                    vewTR[vewtr - 1] = true;

                }

                m2.fire();
            }
        });

        mnsVw.setOnMouseEntered(this::handleButtonEnter);
        mnsVw.setOnMouseExited(this::handleButtonExit);
        mnsVw.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {

                if (vewtr > 1){
                    vewtr = vewtr - 1;

                    trp.setText(String.valueOf(vewtr));
                    vewTR[vewtr]=false;
                }

                m2.fire();
            }
        });

        plTRP.setOnMouseEntered(this::handleButtonEnter);
        plTRP.setOnMouseExited(this::handleButtonExit);
        plTRP.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {

                int inew = Integer.valueOf(trp.getText()) + 1;
                String snew = String.valueOf(inew);

                if (Integer.valueOf(snew) > Integer.valueOf(vewtr)){
                    trp.setText(String.valueOf(vewtr));
                } else{
                    trp.setText(snew);
                }

            }
        });

        mnTRP.setOnMouseEntered(this::handleButtonEnter);
        mnTRP.setOnMouseExited(this::handleButtonExit);
        mnTRP.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {

                int inew = Integer.valueOf(trp.getText()) - 1;
                String snew = String.valueOf(inew);

                if (Integer.valueOf(snew) < 1){
                    trp.setText("1");
                } else{
                    trp.setText(snew);
                }

            }
        });

        plsON.setOnMouseEntered(this::handleButtonEnter);
        plsON.setOnMouseExited(this::handleButtonExit);
        plsON.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {

                int inew = Integer.valueOf(xon.getText()) + 1;
                String snew = String.valueOf(inew);

                if (Integer.valueOf(snew) > 28 ){
                    xon.setText("28");
                } else{
                    xon.setText(snew);
                }

            }
        });

        mnsON.setOnMouseEntered(this::handleButtonEnter);
        mnsON.setOnMouseExited(this::handleButtonExit);
        mnsON.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {

                int inew = Integer.valueOf(xon.getText()) - 1;
                String snew = String.valueOf(inew);

                if (Integer.valueOf(snew) < 1){
                    xon.setText("1");
                } else{
                    xon.setText(snew);
                }

            }
        });

        plOFF.setOnMouseEntered(this::handleButtonEnter);
        plOFF.setOnMouseExited(this::handleButtonExit);
        plOFF.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {

                int inew = Integer.valueOf(xof.getText()) + 1;
                String snew = String.valueOf(inew);

                if (Integer.valueOf(snew) > 28 ){
                    xof.setText("28");
                } else{
                    xof.setText(snew);
                }

            }
        });

        mnOFF.setOnMouseEntered(this::handleButtonEnter);
        mnOFF.setOnMouseExited(this::handleButtonExit);
        mnOFF.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {

                int inew = Integer.valueOf(xof.getText()) - 1;
                String snew = String.valueOf(inew);

                if (Integer.valueOf(snew) < 1){
                    xof.setText("1");
                } else{
                    xof.setText(snew);
                }

            }
        });

        applY.setOnMouseEntered(this::handleButtonEnter);
        applY.setOnMouseExited(this::handleButtonExit);

        glb.setOnMouseEntered(this::handleButtonEnter);
        glb.setOnMouseExited(this::handleButtonExit);

        m.setOnMouseEntered(this::handleButtonEnter);
        m.setOnMouseExited(this::handleButtonExit);

        File output = new File(System.getProperty("user.home"), "\\Desktop");
        FileChooser fileChooser = new FileChooser();
        fileChooser.setInitialDirectory(output);
        //Set extension filter
        fileChooser.getExtensionFilters().add(new FileChooser.ExtensionFilter("png image files (*.png)", "*.png"));

        printer.setOnMouseEntered(this::handleButtonEnter);
        printer.setOnMouseExited(this::handleButtonExit);
        printer.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {

                //Prompt user to select a file
                File file = fileChooser.showSaveDialog(null);

                table.setMinHeight(sizeX((45*vewtr)+30+4));
                table.setMaxHeight(sizeX((45*vewtr)+30+4));

                WritableImage image = table.snapshot(new SnapshotParameters(), null);

                if(file != null) {
                    try {
                        ImageIO.write(SwingFXUtils.fromFXImage(image, null), "png", file);
                        lastPath = file.getParentFile();
                        fileChooser.setInitialDirectory(lastPath);

                    } catch (IOException e) {
                        // TODO: handle exception here
                    }
                }

                table.setMinHeight(sizeX(450));
                table.setMaxHeight(sizeX(450));

            }
        });

        // PROGRAMING TEXT FIELDS BEHAVIOUR:

        tf.setOnMouseEntered(this::handleTextFieldEnter);
        tf.setOnMouseExited(this::handleTextFieldExit);
        tf.textProperty().addListener(new ChangeListener<String>() {
            @Override
            public void changed(ObservableValue<? extends String> observable, String oldValue, String newValue) {

                if (tf.getText().trim().isEmpty()){
                    tf.setText("6");
                } else if (!newValue.matches("([1-9]|(([1]\\d?)|([2][0-4])))?")) {
                    tf.setText(oldValue);
                }

            }
        });

        tfON.setOnMouseEntered(this::handleTextFieldEnter);
        tfON.setOnMouseExited(this::handleTextFieldExit);
        tfON.textProperty().addListener(new ChangeListener<String>() {
            @Override
            public void changed(ObservableValue<? extends String> observable, String oldValue, String newValue) {

                if (tfON.getText().trim().isEmpty()){
                    tfON.setText("42");
                } else if (!newValue.matches("([1-9]|([1-9]\\d?)|([1]\\d?\\d?))?")) {
                    tfON.setText(oldValue);
                }

            }
        });

        tfOFF.setOnMouseEntered(this::handleTextFieldEnter);
        tfOFF.setOnMouseExited(this::handleTextFieldExit);
        tfOFF.textProperty().addListener(new ChangeListener<String>() {
            @Override
            public void changed(ObservableValue<? extends String> observable, String oldValue, String newValue) {

                if (tfOFF.getText().trim().isEmpty()){
                    tfOFF.setText("42");
                } else if (!newValue.matches("([1-9]|([1-9]\\d?)|([1]\\d?\\d?))?")) {
                    tfOFF.setText(oldValue);
                }

            }
        });

        mon.setOnMouseEntered(this::handleTextFieldEnter);
        mon.setOnMouseExited(this::handleTextFieldExit);
        mon.textProperty().addListener(new ChangeListener<String>() {
            @Override
            public void changed(ObservableValue<? extends String> observable, String oldValue, String newValue) {

                if (mon.getText().trim().isEmpty()){
                    mon.setText("6");
                } else if (!newValue.matches("([1-9]|(([1]\\d?)|([2][0-8])))?")) {
                    mon.setText(oldValue);
                }

            }
        });

        mof.setOnMouseEntered(this::handleTextFieldEnter);
        mof.setOnMouseExited(this::handleTextFieldExit);
        mof.textProperty().addListener(new ChangeListener<String>() {
            @Override
            public void changed(ObservableValue<? extends String> observable, String oldValue, String newValue) {

                if (mof.getText().trim().isEmpty()){
                    mof.setText("6");
                } else if (!newValue.matches("([1-9]|(([1]\\d?)|([2][0-8])))?")) {
                    mof.setText(oldValue);
                }

            }
        });

        xon.textProperty().addListener(new ChangeListener<String>() {
            @Override
            public void changed(ObservableValue<? extends String> observable, String oldValue, String newValue) {

                if (xon.getText().trim().isEmpty()){
                    xon.setText(newValue);
                } else if (!newValue.matches("([1-9]|(([1]\\d?)|([2][0-8])))?")) {
                    xon.setText(oldValue);
                }

            }
        });

        xof.textProperty().addListener(new ChangeListener<String>() {
            @Override
            public void changed(ObservableValue<? extends String> observable, String oldValue, String newValue) {

                if (xof.getText().trim().isEmpty()){
                    xof.setText(newValue);
                } else if (!newValue.matches("([1-9]|(([1]\\d?)|([2][0-8])))?")) {
                    xof.setText(oldValue);
                }

            }
        });

        /*
          ###############################################
                 Switching between days and weeks
          ###############################################
        */

        if (toogle.getSelectedToggle().getUserData().toString().equals("day")){

            mnsON.setVisible(false);
            xon.setVisible(false);
            plsON.setVisible(false);
            mnOFF.setVisible(false);
            xof.setVisible(false);
            plOFF.setVisible(false);

            tfON.setVisible(true);
            tfOFF.setVisible(true);

            tfON.setText(String.valueOf(Integer.valueOf(xon.getText())*week));
            tfOFF.setText(String.valueOf(Integer.valueOf(xof.getText())*week));

        } else {

            mnsON.setVisible(true);
            xon.setVisible(true);
            plsON.setVisible(true);
            mnOFF.setVisible(true);
            xof.setVisible(true);
            plOFF.setVisible(true);

            tfON.setVisible(false);
            tfOFF.setVisible(false);

            xon.setText(String.valueOf((int)Math.ceil(Double.valueOf(tfON.getText()))/week));
            xof.setText(String.valueOf((int)Math.ceil(Double.valueOf(tfOFF.getText()))/week));

        }

        /*
          ###############################################
                     Fire main APPLY button
          ###############################################
        */

        b.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {

                printer.setVisible(true);

                String unitOn;
                String unitOff;
                String appendixOn;
                String appendixOff;
                int lengOn;
                int lengOff;

                vbox.getChildren().add(table);

                if (tf.getText().isEmpty()) {tf.setText("4");}

                Integer tf_check = Integer.valueOf(tf.getText());
                vewtr = tf_check;

                if (toogle.getSelectedToggle().getUserData().equals("day")){
                    ton = Integer.valueOf(tfON.getText());
                    toff = Integer.valueOf(tfOFF.getText());

                } else {
                    ton = Integer.valueOf(mon.getText());
                    toff = Integer.valueOf(mof.getText());
                }

                getOn = new String[maxR];
                gtOff = new String[maxR];
                trpNO = new int[maxR];
                timON = new int[maxR];
                sumON = new int[maxR];
                tmOFF = new int[maxR];
                smOFF = new int[maxR];
                weeK = new String[maxR];
                coeF = new int[maxR];
                vewTR = new Boolean[maxR];

                for(int i=0; i<maxR; i++){

                    weeK[i] = toogle.getSelectedToggle().getUserData().toString();

                    if (i<tf_check){
                        vewTR[i]=true;
                    } else {
                        vewTR[i] = false;
                    }

                    if (weeK[i].equals("week")){
                        coeF[i] = week;
                    } else {
                        coeF[i] = 1;
                    }

                    trpNO[i] = i+1;
                    timON[i] = ton*coeF[i];
                    tmOFF[i] = toff*coeF[i];

                    if (i == 0){
                        sumON[i] = 0;
                        smOFF[i] = sumON[i] + timON[i];
                        mainON = timON[i];
                        mainOFF = tmOFF[i];
                    } else {
                        sumON[i] = smOFF[i-1] + tmOFF[i-1];
                        smOFF[i] = sumON[i] + timON[i];
                    }

                    if (weeK[i].equals("week")){
                        lengOn = timON[i]/week;
                        unitOn = "week";
                        if (lengOn == 1){appendixOn = "";} else {appendixOn = "s";}

                    } else if (weeK[i].equals("day") && timON[i]%week==0) {
                        lengOn = timON[i]/week;
                        unitOn = "week";
                        if (lengOn == 1){appendixOn = "";} else {appendixOn = "s";}

                    } else {
                        lengOn = timON[i];
                        unitOn = "day";
                        if (lengOn == 1){appendixOn = "";} else {appendixOn = "s";}

                    }

                    if (weeK[i].equals("week")){
                        lengOff = tmOFF[i]/week;
                        unitOff = "week";
                        if (lengOff == 1){appendixOff = "";} else {appendixOff = "s";}

                    } else if (weeK[i].equals("day") && tmOFF[i]%week==0) {
                        lengOff = tmOFF[i]/week;
                        unitOff = "week";
                        if (lengOff == 1){appendixOff = "";} else {appendixOff = "s";}

                    } else {
                        lengOff = tmOFF[i];
                        unitOff = "day";
                        if (lengOff == 1){appendixOff = "";} else {appendixOff = "s";}

                    }

                    if (vewTR[i] == true) {
                        getOn[i] = dp.getValue().plusDays(sumON[i]).format(DateTimeFormatter.ofPattern(dateCustom));
                        gtOff[i] = dp.getValue().plusDays(smOFF[i]).format(DateTimeFormatter.ofPattern(dateCustom));

                        if (i==1){
                            checkWork = lengOn + " " + unitOn + appendixOn;
                            checkOff = lengOff + " " + unitOff + appendixOff;
                        }

                        data.add(new Rotation(String.valueOf(trpNO[i]), getOn[i], gtOff[i],lengOn + " " + unitOn + appendixOn, lengOff + " " + unitOff + appendixOff));

                    }

                }

                out = 1;

                xon.setText(String.valueOf(timON[Integer.valueOf(trp.getText())-1]));
                xof.setText(String.valueOf(tmOFF[Integer.valueOf(trp.getText())-1]));

                glb.setText("Modify rotations");

                dsply.setVisible(true);
                mnsVw.setVisible(true);
                plsVw.setVisible(true);

                if (toogle.getSelectedToggle().getUserData().toString().equals("day")){
                    mnsON.setVisible(false);
                    xon.setVisible(false);
                    plsON.setVisible(false);
                    mnOFF.setVisible(false);
                    xof.setVisible(false);
                    plOFF.setVisible(false);

                    tfON.setVisible(true);
                    tfOFF.setVisible(true);
                } else {
                    mnsON.setVisible(true);
                    xon.setVisible(true);
                    plsON.setVisible(true);
                    mnOFF.setVisible(true);
                    xof.setVisible(true);
                    plOFF.setVisible(true);

                    tfON.setVisible(false);
                    tfOFF.setVisible(false);
                }

            }
        });

        m.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {

                weeK[Integer.valueOf(trp.getText()) - 1] = toogle.getSelectedToggle().getUserData().toString();

                if (toogle.getSelectedToggle().getUserData().equals("week")) {
                    coeF[Integer.valueOf(trp.getText()) - 1] = week;
                    timON[Integer.valueOf(trp.getText()) - 1] = Integer.valueOf(xon.getText()) * coeF[Integer.valueOf(trp.getText()) - 1];
                    tmOFF[Integer.valueOf(trp.getText()) - 1] = Integer.valueOf(xof.getText()) * coeF[Integer.valueOf(trp.getText()) - 1];
                } else {
                    coeF[Integer.valueOf(trp.getText()) - 1] = 1;
                    timON[Integer.valueOf(trp.getText()) - 1] = Integer.valueOf(tfON.getText());
                    tmOFF[Integer.valueOf(trp.getText()) - 1] = Integer.valueOf(tfOFF.getText());
                }

                m2.fire();
            }
        });

        m2.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {

                data.clear();

                String unitOn;
                String unitOff;
                String appendixOn;
                String appendixOff;
                int lengOn;
                int lengOff;

                for(int i=0; i<maxR; i++){

                    trpNO[i] = i+1;

                    if (i == 0){
                        sumON[i] = 0;
                        smOFF[i] = sumON[i] + timON[i];
                    } else {
                        sumON[i] = smOFF[i-1] + tmOFF[i-1];
                        smOFF[i] = sumON[i] + timON[i];
                    }

                    if (weeK[i].equals("week")){
                        lengOn = timON[i]/week;
                        unitOn = "week";
                        if (lengOn == 1){appendixOn = "";} else {appendixOn = "s";}

                    } else if (weeK[i].equals("day") && timON[i]%week==0) {
                        lengOn = timON[i]/week;
                        unitOn = "week";
                        if (lengOn == 1){appendixOn = "";} else {appendixOn = "s";}

                    } else {
                        lengOn = timON[i];
                        unitOn = "day";
                        if (lengOn == 1){appendixOn = "";} else {appendixOn = "s";}

                    }

                    if (weeK[i].equals("week")){
                        lengOff = tmOFF[i]/week;
                        unitOff = "week";
                        if (lengOff == 1){appendixOff = "";} else {appendixOff = "s";}

                    } else if (weeK[i].equals("day") && tmOFF[i]%week==0) {
                        lengOff = tmOFF[i]/week;
                        unitOff = "week";
                        if (lengOff == 1){appendixOff = "";} else {appendixOff = "s";}

                    } else {
                        lengOff = tmOFF[i];
                        unitOff = "day";
                        if (lengOff == 1){appendixOff = "";} else {appendixOff = "s";}

                    }

                    if(vewTR[i] == true){
                        getOn[i] = dp.getValue().plusDays(sumON[i]).format(DateTimeFormatter.ofPattern(dateCustom));
                        gtOff[i] = dp.getValue().plusDays(smOFF[i]).format(DateTimeFormatter.ofPattern(dateCustom));

                        String testOn = new String(lengOn + " " + unitOn + appendixOn);
                        String testOff = new String(lengOff + " " + unitOff + appendixOff);

                        if (timON[i] != ton){}
                        if (tmOFF[i] != toff){}

                        data.add(new Rotation(String.valueOf(trpNO[i]), getOn[i], gtOff[i], testOn , testOff));

                    }

                }
            }
        });

        glb.setOnAction(new EventHandler<ActionEvent>() {
            @Override
            public void handle(ActionEvent event) {

                final Stage dialog = new Stage();
                dialog.initModality(Modality.APPLICATION_MODAL);
                dialog.initOwner(myStage);

                final BorderPane rootParam = new BorderPane();

                HBox upPrm = new HBox();
                upPrm.setPadding(new Insets(sizeX(15), sizeX(10), sizeX(15), sizeX(10)));
                upPrm.setSpacing(sizeX(10));   // Gap between nodes
                upPrm.setStyle("-fx-background-color: #7BA3CA;");//#336699
                upPrm.setAlignment(Pos.CENTER);
                upPrm.setPrefHeight(sizeX(75));

                TilePane mdPrm = new TilePane();
                mdPrm.setTileAlignment(Pos.CENTER);
                mdPrm.setVgap(sizeX(15));
                mdPrm.setHgap(sizeX(10));
                mdPrm.setAlignment(Pos.CENTER);

                TilePane dwPrm = new TilePane();
                dwPrm.setTileAlignment(Pos.CENTER);
                dwPrm.setVgap(sizeX(10));
                dwPrm.setHgap(sizeX(10));
                dwPrm.setAlignment(Pos.CENTER);
                dwPrm.setPadding(new Insets(sizeX(15), sizeX(30), sizeX(15), sizeX(30)));
                dwPrm.setStyle("-fx-background-color: #7BA3CA;");//#336699,ECC442,7BA3CA,

                AnchorPane anchorApply = new AnchorPane(applY);
                AnchorPane.setTopAnchor(upPrm, 0.0);
                AnchorPane.setRightAnchor(upPrm, 0.0);
                applY.setStyle("-fx-background-color: #7BA3CA;");//#336699
                applY.setPadding(new Insets(sizeX(5),sizeX(5), sizeX(5), sizeX(5)));

                rootParam.setTop(upPrm);
                rootParam.setCenter(mdPrm);
                rootParam.setBottom(dwPrm);

                dialog.setResizable(false);

                Scene dialogScene = new Scene(rootParam);

                rootParam.setPrefSize(sizeX(500), sizeX(273));

                FlowPane flowNodes1 = new FlowPane(sizeX(10),sizeX(10));
                flowNodes1.setPadding(new Insets(sizeX(spcV),sizeX(spcH),sizeX(spcV), sizeX(spcH)));

                FlowPane flowNodes2= new FlowPane(sizeX(10),sizeX(10));
                flowNodes2.setPadding(new Insets(sizeX(0),sizeX(spcH),sizeX(0), sizeX(spcH)));

                VBox spltPne = new VBox(sizeX(5));
                spltPne.setPadding(new Insets(sizeX(25), sizeX(0), sizeX(25), sizeX(0)));

                dialog.getIcons().add(new Image("files/settings.gif"));
                dialog.setScene(dialogScene);

                applY.setOnAction(new EventHandler<ActionEvent>() {
                    @Override
                    public void handle(ActionEvent event) {
                        dialog.close();
                        b.fire();
                    }
                });

                if (out == 0) {

                    toogle.selectedToggleProperty().addListener(new ChangeListener<Toggle>() {
                        public void changed(ObservableValue<? extends Toggle> ov,
                                            Toggle old_toggle, Toggle new_toggle) {

                            if (toogle.getSelectedToggle().getUserData().toString().equals("day")){

                                mon.setVisible(false);
                                mof.setVisible(false);

                                tfON.setVisible(true);
                                tfOFF.setVisible(true);

                            } else {

                                mon.setVisible(true);
                                mof.setVisible(true);

                                tfON.setVisible(false);
                                tfOFF.setVisible(false);

                            }
                        }
                    });

                    dialog.setTitle("Set main parameters for calculation");

                    upPrm.getChildren().addAll(rotNO, minus, tf, plus);
                    mdPrm.getChildren().addAll(modON, mon, tfON, modOF, mof, tfOFF);
                    dwPrm.getChildren().addAll(modTM, radio2, radio1);
                    upPrm.getChildren().add(anchorApply);

                } else {

                    trp.textProperty().addListener(new ChangeListener<String>() {
                        @Override
                        public void changed(ObservableValue<? extends String> observable, String oldValue, String newValue) {

                            xon.setText(String.valueOf((int)Math.ceil(timON[Integer.valueOf(trp.getText())-1]/week)));
                            xof.setText(String.valueOf((int)Math.ceil(tmOFF[Integer.valueOf(trp.getText())-1]/week)));

                            tfON.setText(String.valueOf(timON[Integer.valueOf(trp.getText())-1]));
                            tfOFF.setText(String.valueOf(tmOFF[Integer.valueOf(trp.getText())-1]));

                        }
                    });

                    toogle.selectedToggleProperty().addListener(new ChangeListener<Toggle>() {
                        public void changed(ObservableValue<? extends Toggle> ov,
                                            Toggle old_toggle, Toggle new_toggle) {

                            if (toogle.getSelectedToggle().getUserData().toString().equals("day")){
                                mnsON.setVisible(false);
                                xon.setVisible(false);
                                plsON.setVisible(false);
                                mnOFF.setVisible(false);
                                xof.setVisible(false);
                                plOFF.setVisible(false);

                                tfON.setVisible(true);
                                tfOFF.setVisible(true);

                                tfON.setText(String.valueOf(Integer.valueOf(xon.getText())*week)); //test!
                                tfOFF.setText(String.valueOf(Integer.valueOf(xof.getText())*week)); //test!

                            } else {
                                mnsON.setVisible(true);
                                xon.setVisible(true);
                                plsON.setVisible(true);
                                mnOFF.setVisible(true);
                                xof.setVisible(true);
                                plOFF.setVisible(true);

                                tfON.setVisible(false);
                                tfOFF.setVisible(false);

                                xon.setText(String.valueOf((int)Math.ceil(Double.valueOf(tfON.getText()))/week)); //test!
                                xof.setText(String.valueOf((int)Math.ceil(Double.valueOf(tfOFF.getText()))/week)); //test!

                            }

                        }
                    });

                    dialog.setTitle("Amend individual work rotation");

                    HBox dwBox = new HBox();
                    dwBox.setSpacing(sizeX(10));
                    dwBox.setPadding(new Insets(sizeX(15), sizeX(30), sizeX(15), sizeX(30)));
                    dwBox.setStyle("-fx-background-color: #7BA3CA;" +
                            "-fx-font: " + sizeX(18) + "px \"Candara\";"); //OldGood: [Calibri, Book Antiqua]

                    flowNodes1.setAlignment(Pos.CENTER_LEFT);
                    flowNodes2.setAlignment(Pos.CENTER_LEFT);
                    upPrm.setAlignment(Pos.CENTER_LEFT);
                    dwBox.setAlignment(Pos.CENTER_LEFT);

                    m.setTranslateX(sizeX(30));
                    tfON.setTranslateX(sizeX(45));
                    tfOFF.setTranslateX(sizeX(45));
                    radio1.setTranslateX(sizeX(65));

                    rootParam.setPrefSize(sizeX(500-93), sizeX(273));
                    rootParam.setBottom(dwBox);
                    rootParam.setCenter(spltPne);

                    upPrm.getChildren().addAll(modTL, mnTRP, trp, plTRP, m);
                    flowNodes1.getChildren().addAll(nodON, mnsON, xon, plsON, tfON);
                    flowNodes2.getChildren().addAll(nodOF, mnOFF, xof, plOFF, tfOFF);
                    spltPne.getChildren().addAll(flowNodes1, flowNodes2);
                    dwBox.getChildren().addAll(nodTM, radio2, radio1);

                }

                dialog.show();
            }
        });

        myStage.show();
    }

    public static class Rotation {

        private final SimpleStringProperty rotationNo;
        private final SimpleStringProperty rotationFrom;
        private final SimpleStringProperty rotationUntil;
        private final SimpleStringProperty periodWork;
        private final SimpleStringProperty periodOff;

        private Rotation(String xTrip, String fTrip, String uTrip, String lTrip, String lOff) {
            this.rotationNo = new SimpleStringProperty(xTrip);
            this.rotationFrom = new SimpleStringProperty(fTrip);
            this.rotationUntil = new SimpleStringProperty(uTrip);
            this.periodWork = new SimpleStringProperty(lTrip);
            this.periodOff = new SimpleStringProperty(lOff);
        }

        public String getRotationNo() {
            return rotationNo.get();
        }

        public void setRotationNo(String xTrip) {
            rotationNo.set(xTrip);
        }

        public String getRotationFrom() {
            return rotationFrom.get();
        }

        public void setRotationFrom(String xTrip) {
            rotationFrom.set(xTrip);
        }

        public String getRotationUntil() {
            return rotationUntil.get();
        }

        public void setRotationUntil(String xTrip) {
            rotationUntil.set(xTrip);
        }

        public String getPeriodWork() {
            return periodWork.get();
        }

        public void setPeriodWork(String xTrip) {
            periodWork.set(xTrip);
        }

        public String getPeriodOff() {
            return periodOff.get();
        }

        public void setPeriodOff(String xTrip) {
            periodOff.set(xTrip);
        }

    }

    public static void main(String[] args) {
        launch(args);
    }
}
