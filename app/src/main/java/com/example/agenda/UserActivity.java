package com.example.agenda;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class UserActivity extends AppCompatActivity {
    TextView rtLogin;
    Button btCadastrar, btAlterar, btExcluir, btListar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_user);

        rtLogin = findViewById(R.id.rtLog);
        btCadastrar = findViewById(R.id.btCadastrar);
        btAlterar = findViewById(R.id.btAlterar);
        btExcluir = findViewById(R.id.btListrar);
        btListar = findViewById(R.id.btListrar);

        btCadastrar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(getBaseContext(), CadCompActivity.class);
                startActivity(intent);
            }
        });

        btListar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent intent = new Intent(getBaseContext(), ListrarCompActivity.class);
                startActivity(intent);
            }
        });

    }
}
