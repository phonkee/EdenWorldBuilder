/******************************************************************************

 @File         PVRTPrint3DAPI.cpp

 @Title        OGLES/PVRTPrint3DAPI

 @Version      

 @Copyright    Copyright (C)  Imagination Technologies Limited.

 @Platform     ANSI compatible

 @Description  Displays a text string using 3D polygons. Can be done in two ways:
               using a window defined by the user or writing straight on the
               screen.

******************************************************************************/

/****************************************************************************
** Includes
****************************************************************************/
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "PVRTContext.h"
#include "PVRTFixedPoint.h"
#include "PVRTMatrix.h"
#include "PVRTPrint3D.h"
#include "PVRTglesExt.h"
#include "PVRTTexture.h"
#include "PVRTTextureAPI.h"

/****************************************************************************
** Defines
****************************************************************************/

/****************************************************************************
** Structures
****************************************************************************/

struct SPVRTPrint3DAPI
{
	GLuint	uTexture[5];
	GLuint	uTexturePVRLogo;
	GLuint	uTextureIMGLogo;
	bool	IsVGPSupported;
};

/****************************************************************************
** Class: CPVRTPrint3D
****************************************************************************/

/*!***************************************************************************
 @Function			ReleaseTextures
 @Description		Deallocate the memory allocated in SetTextures(...)
*****************************************************************************/
void CPVRTPrint3D::ReleaseTextures()
{
#if !defined (DISABLE_PRINT3D)

	/* Only release textures if they've been allocated */
	if (!m_bTexturesSet) return;

	/* Release IndexBuffer */
	FREE(m_pwFacesFont);
	FREE(m_pPrint3dVtx);

	/* Delete textures */
	glDeleteTextures(5, m_pAPI->uTexture);
	glDeleteTextures(1, &m_pAPI->uTexturePVRLogo);
	glDeleteTextures(1, &m_pAPI->uTextureIMGLogo);

	m_bTexturesSet = false;

	FREE(m_pVtxCache);

	APIRelease();

#endif
}

/*!***************************************************************************
 @Function			Flush
 @Description		Flushes all the print text commands
*****************************************************************************/
int CPVRTPrint3D::Flush()
{
#if !defined (DISABLE_PRINT3D)

	int		nTris, nVtx, nVtxBase, nTrisTot;

	_ASSERT((m_nVtxCache % 4) == 0);
	_ASSERT(m_nVtxCache <= m_nVtxCacheMax);

	/* Save render states */
	APIRenderStates(0);

	/* Set font texture */
	glBindTexture(GL_TEXTURE_2D, m_pAPI->uTexture[0]);

	/* Set blending mode */
	glEnable(GL_BLEND);

	nTrisTot = m_nVtxCache >> 1;

	/*
		Render the text then. Might need several submissions.
	*/
	nVtxBase = 0;
	while(m_nVtxCache)
	{
		nVtx	= PVRT_MIN(m_nVtxCache, 0xFFFC);
		nTris	= nVtx >> 1;

		_ASSERT(nTris <= (PVRTPRINT3D_MAX_RENDERABLE_LETTERS*2));
		_ASSERT((nVtx % 4) == 0);

		/* Draw triangles */
		glVertexPointer(3,		VERTTYPEENUM,		sizeof(SPVRTPrint3DAPIVertex), &m_pVtxCache[nVtxBase].sx);
		glColorPointer(4,		GL_UNSIGNED_BYTE,	sizeof(SPVRTPrint3DAPIVertex), &m_pVtxCache[nVtxBase].color);
		glTexCoordPointer(2,	VERTTYPEENUM,		sizeof(SPVRTPrint3DAPIVertex), &m_pVtxCache[nVtxBase].tu);
		glDrawElements(GL_TRIANGLES, nTris * 3, GL_UNSIGNED_SHORT, m_pwFacesFont);
		if (glGetError())
		{
			_RPT0(_CRT_WARN,"glDrawElements(GL_TRIANGLES, (VertexCount/2)*3, GL_UNSIGNED_SHORT, m_pFacesFont); failed\n");
		}

		nVtxBase		+= nVtx;
		m_nVtxCache	-= nVtx;
	}

	/* Draw a logo if requested */
#if defined(FORCE_NO_LOGO)
	/* Do nothing */

#elif defined(FORCE_PVR_LOGO)
    APIDrawLogo(ePVRTPrint3DLogoPVR, 1);	/* PVR to the right */

#elif defined(FORCE_IMG_LOGO)
	APIDrawLogo(ePVRTPrint3DLogoIMG, 1);	/* IMG to the right */

#elif defined(FORCE_ALL_LOGOS)
	APIDrawLogo(ePVRTPrint3DLogoIMG, -1); /* IMG to the left */
	APIDrawLogo(ePVRTPrint3DLogoPVR, 1);	/* PVR to the right */

#else
	/* User selected logos */
	switch (m_uLogoToDisplay)
	{
		case ePVRTPrint3DLogoNone:
			break;
		default:
		case ePVRTPrint3DLogoPVR:
			APIDrawLogo(ePVRTPrint3DLogoPVR, 1);	/* PVR to the right */
			break;
		case ePVRTPrint3DLogoIMG:
			APIDrawLogo(ePVRTPrint3DLogoIMG, 1);	/* IMG to the right */
			break;
		case (ePVRTPrint3DLogoPVR | ePVRTPrint3DLogoIMG):
			APIDrawLogo(ePVRTPrint3DLogoIMG, -1); /* IMG to the left */
			APIDrawLogo(ePVRTPrint3DLogoPVR, 1);	/* PVR to the right */
			break;
	}
#endif

	/* Restore render states */
	APIRenderStates(1);

	return nTrisTot;

#else
	return 0;
#endif
}

/*************************************************************
*					 PRIVATE FUNCTIONS						 *
**************************************************************/

/*!***************************************************************************
 @Function			APIInit
 @Description		Initialization and texture upload. Should be called only once
					for a given context.
*****************************************************************************/
bool CPVRTPrint3D::APIInit(const SPVRTContext	* const /*pContext*/)
{
	m_pAPI = new SPVRTPrint3DAPI;
	if(!m_pAPI)
		return false;

	m_pAPI->IsVGPSupported = CPVRTglesExt::IsGLExtensionSupported("GL_IMG_vertex_program");

	return true;
}

/*!***************************************************************************
 @Function			APIRelease
 @Description		Deinitialization.
*****************************************************************************/
void CPVRTPrint3D::APIRelease()
{
	delete m_pAPI;
	m_pAPI = 0;
}

/*!***************************************************************************
 @Function			APIUpLoadIcons
 @Description		Initialization and texture upload. Should be called only once
					for a given context.
*****************************************************************************/
bool CPVRTPrint3D::APIUpLoadIcons(
	const PVRTuint32 * const pPVR,
	const PVRTuint32 * const pIMG)
{
	/* Load Icon textures */
	if(PVRTTextureLoadFromPointer((unsigned char*)pPVR, &m_pAPI->uTexturePVRLogo) != PVR_SUCCESS)
		return false;
	if(PVRTTextureLoadFromPointer((unsigned char*)pIMG, &m_pAPI->uTextureIMGLogo) != PVR_SUCCESS)
		return false;

	return true;
}

/*!***************************************************************************
 @Function			APIUpLoad4444
 @Return			true if succesful, false otherwise.
 @Description		Reads texture data from *.dat and loads it in
					video memory.
*****************************************************************************/
bool CPVRTPrint3D::APIUpLoad4444(unsigned int dwTexID, unsigned char *pSource, unsigned int nSize, unsigned int nMode)
{
	int				i, j;
	int				x=256, y=256;
	unsigned short	R, G, B, A;
	unsigned short	*p8888,  *pDestByte;
	unsigned char   *pSrcByte;

	/* Only square textures */
	x = nSize;
	y = nSize;

	glGenTextures(1, &m_pAPI->uTexture[dwTexID]);

	/* Load texture from data */

	/* Format is 4444-packed, expand it into 8888 */
	if (nMode==0)
	{
		/* Allocate temporary memory */
		p8888 = (unsigned short *)malloc(nSize*nSize*sizeof(unsigned short));		if(!p8888)
		{
			PVRTErrorOutputDebug("Not enough memory!\n");
			return false;
		}

		pDestByte = p8888;

		/* Set source pointer (after offset of 16) */
		pSrcByte = &pSource[16];

		/* Transfer data */
		for (i=0; i<y; i++)
		{
			for (j=0; j<x; j++)
			{
				/* Get all 4 colour channels (invert A) */
				G =   (*pSrcByte) & 0xF0;
				R = ( (*pSrcByte++) & 0x0F ) << 4;
				A =   (*pSrcByte) ^ 0xF0;
				B = ( (*pSrcByte++) & 0x0F ) << 4;

				/* Set them in 8888 data */
				*pDestByte++ = ((R&0xF0)<<8) | ((G&0xF0)<<4) | (B&0xF0) | (A&0xF0)>>4;
			}
		}
	}
	else
	{
		/* Set source pointer */
		pSrcByte = pSource;

		/* Allocate temporary memory */
		p8888 = (unsigned short *)malloc(nSize*nSize*sizeof(unsigned short));		if(!p8888)
		if(!p8888)
		{
			PVRTErrorOutputDebug("Not enough memory!\n");
			return false;
		}


		/* Set destination pointer */
		pDestByte = p8888;

		/* Transfer data */
		for (i=0; i<y; i++)
		{
			for (j=0; j<x; j++)
			{
				/* Get alpha channel */
				A = *pSrcByte++;

				/* Set them in 8888 data */
				R = 255;
				G = 255;
				B = 255;

				/* Set them in 8888 data */
				*pDestByte++ = ((R&0xF0)<<8) | ((G&0xF0)<<4) | (B&0xF0) | (A&0xF0)>>4;
			}
		}
	}

	/* Bind texture */
	glBindTexture(GL_TEXTURE_2D, m_pAPI->uTexture[dwTexID]);

	/* Default settings: bilinear */
	myglTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	myglTexParameter(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	/* Now load texture */
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, x, y, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, p8888);
	if (glGetError())
	{
		_RPT0(_CRT_WARN,"glTexImage2D() failed\n");
		free(p8888);
		return false;
	}

	/* Destroy temporary data */
	free(p8888);

	/* Return status : OK */
	return true;
}

/*!***************************************************************************
 @Function			DrawBackgroundWindowUP
 @Description
*****************************************************************************/
void CPVRTPrint3D::DrawBackgroundWindowUP(SPVRTPrint3DAPIVertex *pVtx, const bool bIsOp, const bool bBorder)
{
	const unsigned short c_pwFacesWindow[] =
	{
		0,1,2, 2,1,3, 2,3,4, 4,3,5, 4,5,6, 6,5,7, 5,8,7, 7,8,9, 8,10,9, 9,10,11, 8,12,10, 8,13,12,
		13,14,12, 13,15,14, 13,3,15, 1,15,3, 3,13,5, 5,13,8
	};

	/* Set the texture (with or without border) */
	if(!bBorder)
		glBindTexture(GL_TEXTURE_2D, m_pAPI->uTexture[2 + (bIsOp*2)]);
	else
		glBindTexture(GL_TEXTURE_2D, m_pAPI->uTexture[1 + (bIsOp*2)]);

	/* Is window opaque ? */
	if(bIsOp)
	{
		glDisable(GL_BLEND);
	}
	else
	{
		/* Set blending properties */
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}

	/* Set pointers */
	glVertexPointer(3,		VERTTYPEENUM,		sizeof(SPVRTPrint3DAPIVertex), &pVtx[0].sx);
	glColorPointer(4,		GL_UNSIGNED_BYTE,	sizeof(SPVRTPrint3DAPIVertex), &pVtx[0].color);
	glTexCoordPointer(2,	VERTTYPEENUM,		sizeof(SPVRTPrint3DAPIVertex), &pVtx[0].tu);

	/* Draw triangles */
	glDrawElements(GL_TRIANGLES, 18*3, GL_UNSIGNED_SHORT, c_pwFacesWindow);
	if (glGetError())
	{
		PVRTErrorOutputDebug("glDrawElements(GL_TRIANGLES, 18*3, GL_UNSIGNED_SHORT, pFaces); failed\n");
	}

	/* Restore render states (need to be translucent to draw the text) */
}

/*!***************************************************************************
 @Function			APIRenderStates
 @Description		Stores, writes and restores Render States
*****************************************************************************/
void CPVRTPrint3D::APIRenderStates(int nAction)
{
	PVRTMATRIX			Matrix;

	// Saving or restoring states ?
	switch (nAction)
	{
	case 0:
		/******************************
		** SET PRINT3D RENDER STATES **
		******************************/
		// Set matrix with viewport dimensions
		Matrix.f[0] =	f2vt(2.0f/(m_fScreenScale[0]*640.0f));
		Matrix.f[1] = Matrix.f[2] = Matrix.f[3] = Matrix.f[4] = 0;
		Matrix.f[5] =	f2vt(-2.0f/(m_fScreenScale[1]*480.0f));
		Matrix.f[6] = Matrix.f[7] = Matrix.f[8] = Matrix.f[9] = 0;
		Matrix.f[10] = f2vt(1.0f);
		Matrix.f[11] = 0;
		Matrix.f[12] = f2vt(-1.0f);
		Matrix.f[13] = f2vt(1.0f);
		Matrix.f[14] = 0;
		Matrix.f[15] = f2vt(1.0f);

		// Set matrix modes
		glMatrixMode(GL_PROJECTION);
		glPushMatrix();
		glLoadIdentity();

		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
		myglLoadMatrix(Matrix.f);

		// Disable lighting
		glDisable(GL_LIGHTING);

		// Culling
		glEnable(GL_CULL_FACE);
		glFrontFace(GL_CW);
		glCullFace(GL_FRONT);

		// Set client states
		glEnableClientState(GL_VERTEX_ARRAY);
		glEnableClientState(GL_COLOR_ARRAY);

		glClientActiveTexture(GL_TEXTURE0);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);

		// texture
		glActiveTexture(GL_TEXTURE1);
		glDisable(GL_TEXTURE_2D);
		glActiveTexture(GL_TEXTURE0);
		glEnable(GL_TEXTURE_2D);
		myglTexEnv(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE);

		// Blending mode
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		// Disable fog
		glDisable(GL_FOG);

		// Set Z compare properties
		glDisable(GL_DEPTH_TEST);

		// Disable vertex program
		if(m_pAPI->IsVGPSupported)
			glDisable(GL_VERTEX_PROGRAM_ARB);

#if defined(GL_OES_VERSION_1_1) || defined(GL_VERSION_ES_CM_1_1) || defined(GL_VERSION_ES_CL_1_1)
		// unbind the VBO for the mesh
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
#endif
		break;

	case 1:
		// Restore render states
		glDisableClientState(GL_VERTEX_ARRAY);
		glDisableClientState(GL_COLOR_ARRAY);
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);

		// Restore matrix mode & matrix
		glMatrixMode(GL_PROJECTION);
		glPopMatrix();
		glMatrixMode(GL_MODELVIEW);
		glPopMatrix();
		break;
	}
}

/****************************************************************************
** Local code
****************************************************************************/

/*!***************************************************************************
 @Function			APIDrawLogo
 @Description		nPos = -1 to the left
					nPos = +1 to the right
*****************************************************************************/
void CPVRTPrint3D::APIDrawLogo(unsigned int uLogoToDisplay, int nPos)
{
	const float fLogoSizeHalf = 0.15f;
	const float fLogoShift = 0.05f;
	const float fLogoSizeHalfShifted = fLogoSizeHalf + fLogoShift;
	const float fLogoYScale = 50.0f / 64.0f;

	static VERTTYPE	Vertices[] =
		{
			f2vt(-fLogoSizeHalf), f2vt(fLogoSizeHalf) , f2vt(0.5f),
			f2vt(-fLogoSizeHalf), f2vt(-fLogoSizeHalf), f2vt(0.5f),
			f2vt(fLogoSizeHalf)	, f2vt(fLogoSizeHalf) , f2vt(0.5f),
	 		f2vt(fLogoSizeHalf)	, f2vt(-fLogoSizeHalf), f2vt(0.5f)
		};

	static VERTTYPE	Colours[] = {
			f2vt(1.0f), f2vt(1.0f), f2vt(1.0f), f2vt(0.75f),
			f2vt(1.0f), f2vt(1.0f), f2vt(1.0f), f2vt(0.75f),
			f2vt(1.0f), f2vt(1.0f), f2vt(1.0f), f2vt(0.75f),
	 		f2vt(1.0f), f2vt(1.0f), f2vt(1.0f), f2vt(0.75f)
		};

	static VERTTYPE	UVs[] = {
			f2vt(0.0f), f2vt(0.0f),
			f2vt(0.0f), f2vt(1.0f),
			f2vt(1.0f), f2vt(0.0f),
	 		f2vt(1.0f), f2vt(1.0f)
		};

	VERTTYPE *pVertices = ( (VERTTYPE*)&Vertices );
	VERTTYPE *pColours  = ( (VERTTYPE*)&Colours );
	VERTTYPE *pUV       = ( (VERTTYPE*)&UVs );
	GLuint	tex;

	switch(uLogoToDisplay)
	{
	case ePVRTPrint3DLogoIMG:
		tex = m_pAPI->uTextureIMGLogo;
		break;
	default:
		tex = m_pAPI->uTexturePVRLogo;
		break;
	}

	// Matrices
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	float fScreenScale = PVRT_MIN(m_ui32ScreenDim[0], m_ui32ScreenDim[1]) / 480.0f;
	float fScaleX = (640.0f / m_ui32ScreenDim[0]) * fScreenScale;
	float fScaleY = (480.0f / m_ui32ScreenDim[1]) * fScreenScale * fLogoYScale;

	if(m_bRotate)
		myglRotate(f2vt(90), f2vt(0), f2vt(0), f2vt(1));

	myglTranslate(f2vt(nPos - (fLogoSizeHalfShifted * fScaleX * nPos)), f2vt(-1.0f + (fLogoSizeHalfShifted * fScaleY)), f2vt(0.0f));
	myglScale(f2vt(fScaleX), f2vt(fScaleY), f2vt(1.0f));

	// Render states
	glActiveTexture(GL_TEXTURE0);
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, tex);

	glDisable(GL_DEPTH_TEST);

	glEnable (GL_BLEND);
	glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	// Vertices
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(3,VERTTYPEENUM,0,pVertices);

	glEnableClientState(GL_COLOR_ARRAY);
	glColorPointer(4,VERTTYPEENUM,0,pColours);

	glClientActiveTexture(GL_TEXTURE0);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glTexCoordPointer(2,VERTTYPEENUM,0,pUV);

	glDrawArrays(GL_TRIANGLE_STRIP,0,4);

	glDisableClientState(GL_VERTEX_ARRAY);

	glDisableClientState(GL_COLOR_ARRAY);

	glClientActiveTexture(GL_TEXTURE0);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);

	// Restore render states
	glDisable (GL_BLEND);
	glEnable(GL_DEPTH_TEST);
}

/*****************************************************************************
 End of file (PVRTPrint3DAPI.cpp)
*****************************************************************************/

