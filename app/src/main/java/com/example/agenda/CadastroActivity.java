package com.example.agenda;

import androidx.appcompat.app.AppCompatActivity;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class CadastroActivity extends AppCompatActivity {
    TextView ctnome, ctEmail,ctSenha, ctRepSenha;
    Button btSalvar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_cadastro);

        ctnome = findViewById(R.id.ctNome);
        ctEmail = findViewById(R.id.ctEmail);
        ctSenha = findViewById(R.id.ctSenha);
        ctRepSenha = findViewById(R.id.ctRepSenha);
        btSalvar = findViewById(R.id.btSalvar);

        btSalvar.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                Intent i = new Intent(getBaseContext(), MainActivity.class);
                startActivity(i);
            }
        });

    }
}
