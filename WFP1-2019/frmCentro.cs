﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using INF518Core.Clases;

namespace WFP1_2019
{
    public partial class frmCentro : Form
    {
        public frmCentro()
        {
            InitializeComponent();
            this.centro = new Centro();
        }
        Centro centro;

        private void btnGuardar_Click(object sender, EventArgs e)
        {
            if (this.ValidarFormulario())
            {
                if (this.centro.CentroID > 0)
                {
                    Actualizar();
                }
                else
                {
                    Registrar();
                }
            }
            else
            {
                MessageBox.Show("Los campos con (*) son obligatorios");
            }
        }


        public bool ValidarFormulario()
        {
            foreach (var item in groupBox1.Controls)
            {
                if (item.GetType() == typeof(TextBox))
                {
                    if (((TextBox)item).Tag.ToString() == "*" && ((TextBox)item).Text == "")
                    {
                        return false;
                    }
                }
            }
            return true;
        }

        public void Actualizar()
        {

        }

        public void Registrar()
        {
            AsignarValores();
            if (this.centro.Registrar())
            {
                MessageBox.Show("Se ha registrado correctamente", "Mensaje", MessageBoxButtons.OK, MessageBoxIcon.Information);
                this.Close();
            }
            else
            {
                MessageBox.Show("No se pudo realizar el registro", "Mensaje", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        public void AsignarValores()
        {
            this.centro.Nombre = txtNombre.Text;
            this.centro.NombreCorto = txtNombreCotro.Text;
            this.centro.WebSite = txtWebSite.Text;
            this.centro.Telefono = txtTelefono.Text;
            this.centro.Observaciones = txtObservaciones.Text;
        }

        private void btnCancelar_Click(object sender, EventArgs e)
        {
            this.Close();
        }
    }
}
