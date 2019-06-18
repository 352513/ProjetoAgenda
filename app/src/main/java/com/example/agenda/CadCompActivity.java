package com.example.agenda;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class CadCompActivity extends AppCompatActivity {
    TextView ctCompromisso, ctHorario, ctLocal, ctData;
    Button btRegistar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_cad_comp);

        ctCompromisso = findViewById(R.id.ctCompromisso);
        ctHorario = findViewById(R.id.ctHorario);
        ctLocal = findViewById(R.id.ctLocal);
        ctData = findViewById(R.id.ctData);
        btRegistar = findViewById(R.id.btregistrar);

        btRegistar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
              finish();
            }
        });


    }
}
